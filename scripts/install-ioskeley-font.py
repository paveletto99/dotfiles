#!/usr/bin/env python3
"""Install only Normal-width NF faces from the requested Ioskeley release archive."""

import argparse
import hashlib
import io
import json
from pathlib import Path
import struct
import subprocess
import sys
import urllib.request
import zipfile

FONT_URL = "https://github.com/ahatem/IoskeleyMono/releases/latest/download/IoskeleyMono-NerdFont.zip"
FONT_FAMILY = "IoskeleyMono Nerd Font"


def font_family_name(contents):
    """Read a font's preferred family from its SFNT name table."""
    table_count = struct.unpack_from(">H", contents, 4)[0]
    for index in range(table_count):
        tag, _, offset, _ = struct.unpack_from(">4sIII", contents, 12 + index * 16)
        if tag != b"name":
            continue
        _, count, strings = struct.unpack_from(">HHH", contents, offset)
        candidates = []
        for record in range(count):
            platform, _, language, name_id, length, position = struct.unpack_from(
                ">HHHHHH", contents, offset + 6 + record * 12
            )
            if name_id not in (1, 16):
                continue
            raw = contents[offset + strings + position:offset + strings + position + length]
            value = raw.decode("utf-16-be" if platform in (0, 3) else "mac_roman")
            candidates.append(((name_id == 16, language in (0, 1033)), value))
        if candidates:
            return max(candidates)[1]
    raise ValueError("Ioskeley font family metadata missing")


def installed_font_status(directory):
    """Check owned font files against their saved digests without network access."""
    marker = directory / "installed.json"
    if not marker.exists():
        return False
    data = json.loads(marker.read_text())
    if data.get("url") != FONT_URL or not data.get("files"):
        return False
    return all(
        (directory / name).is_file()
        and hashlib.sha256((directory / name).read_bytes()).hexdigest() == digest
        for name, digest in data["files"].items()
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--platform", choices=["darwin", "linux"], default=sys.platform)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    directory = Path.home() / (
        "Library/Fonts/IoskeleyMono" if args.platform == "darwin"
        else ".local/share/fonts/IoskeleyMono"
    )
    if installed_font_status(directory):
        print("Ioskeley Mono Nerd Font is installed and matches its recorded digests.")
        return 0
    if args.check:
        print("Ioskeley Mono Nerd Font is missing or changed.", file=sys.stderr)
        return 1
    cache = Path(__file__).resolve().parents[1] / ".cache"
    archive_file = cache / "IoskeleyMono-NerdFont.zip"
    url_file = cache / "IoskeleyMono-resolved-url"
    if archive_file.exists() and url_file.exists():
        archive_bytes = archive_file.read_bytes()
        resolved_url = url_file.read_text().strip()
    else:
        request = urllib.request.Request(FONT_URL, headers={"User-Agent": "dotfiles-font-installer"})
        with urllib.request.urlopen(request, timeout=120) as response:
            archive_bytes = response.read()
            resolved_url = response.url
        cache.mkdir(exist_ok=True)
        archive_file.write_bytes(archive_bytes)
        url_file.write_text(resolved_url)
    hinting = "Unhinted" if args.platform == "darwin" else "Hinted"
    selected = {}
    families = set()
    with zipfile.ZipFile(io.BytesIO(archive_bytes)) as archive:
        has_hinting = any("Unhinted" in Path(entry.filename).parts for entry in archive.infolist())
        for entry in archive.infolist():
            parts = Path(entry.filename).parts
            if not entry.filename.lower().endswith((".ttf", ".otf")):
                continue
            # Exact path components avoid matching SemiCondensed or Unhinted/Hinted.
            if "Normal" not in parts or (has_hinting and hinting not in parts):
                continue
            contents = archive.read(entry)
            family = font_family_name(contents)
            if family != FONT_FAMILY:
                continue
            name = Path(entry.filename).name
            if name in selected:
                raise ValueError(f"Duplicate Ioskeley font filename: {name}")
            selected[name] = contents
            families.add(family)
    if not selected:
        raise ValueError("Ioskeley archive has no matching Normal-width Nerd Font faces")
    directory.mkdir(parents=True, exist_ok=True)
    # This directory is dedicated to this installer; unrelated installed fonts stay intact.
    for name, contents in selected.items():
        target = directory / name
        if target.exists() and target.read_bytes() != contents:
            raise ValueError(f"Ioskeley font conflict: back up {target} before updating")
        target.write_bytes(contents)
    metadata = {
        "url": FONT_URL, "resolved_url": resolved_url,
        "archive_sha256": hashlib.sha256(archive_bytes).hexdigest(),
        "families": sorted(families), "hinting": hinting,
        "files": {name: hashlib.sha256(data).hexdigest() for name, data in selected.items()},
    }
    if not has_hinting:
        metadata["hinting"] = "Bundled (no separate hinting variants in archive)"
    (directory / "installed.json").write_text(json.dumps(metadata, indent=2) + "\n")
    if args.platform == "linux":
        subprocess.run(["fc-cache", "-f", str(directory)], check=True)
    print(f"Installed {len(selected)} faces ({metadata['hinting']}): {', '.join(sorted(families))}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, zipfile.BadZipFile) as error:
        print(f"Ioskeley font installation failed: {error}", file=sys.stderr)
        sys.exit(1)
