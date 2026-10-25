#!/usr/bin/env python3
"""Regenerate the complete Homebrew inventory from installed package receipts."""

import datetime
import json
import os
from pathlib import Path
import subprocess


def brew_output(*arguments):
    """Read Homebrew metadata without auto-updating or installing packages."""
    environment = dict(os.environ, HOMEBREW_NO_AUTO_UPDATE="1")
    return subprocess.check_output(["brew", *arguments], text=True, env=environment).strip()


def main():
    root = Path(__file__).resolve().parents[1]
    cellar = Path(brew_output("--cellar"))
    lines = [
        "# Homebrew inventory", "",
        f"Generated {datetime.date.today().isoformat()} by `python3 scripts/inventory-homebrew.py`.",
        "Observed installed state, including dependencies; presence does not establish active use.",
        "`Brewfile` defines the intended managed tools. REVIEW entries remain manual decisions.",
        "", "## Taps", "",
    ]
    lines.extend(f"- `{tap}`" for tap in brew_output("tap").splitlines())
    lines.extend(["", "## Formulae", "", "| Formula | Installed version | Origin | Installation reason |", "| --- | --- | --- | --- |"])
    formulae = brew_output("list", "--formula", "--versions").splitlines()
    for line in formulae:
        name, *versions = line.split()
        for version in versions:
            receipt = cellar / name / version / "INSTALL_RECEIPT.json"
            data = json.loads(receipt.read_text()) if receipt.exists() else {}
            tap = data.get("source", {}).get("tap", "unknown")
            if data.get("installed_on_request"):
                reason = "Explicit"
            elif data.get("installed_as_dependency"):
                reason = "Dependency"
            else:
                reason = "REVIEW: not recorded"
            lines.append(f"| `{name}` | `{version}` | `{tap}` | {reason} |")
    lines.extend(["", "## Casks", "", "| Cask | Installed version |", "| --- | --- |"])
    casks = brew_output("list", "--cask", "--versions").splitlines()
    for line in casks:
        name, *versions = line.split()
        lines.append(f"| `{name}` | `{' '.join(versions)}` |")
    lines.extend([
        "", "## Tools installed outside Homebrew", "",
        "- macOS system Zsh; Apple Command Line Tools.",
        "- Rust via rustup, Cargo-installed exa (its shell alias is now inactive).",
        "- Bun in `~/.bun`; Herdr in `~/.local/bin`.",
        "- Ghostty, Zed Preview and VS Code Insiders installed as macOS applications.",
        "- Ioskeley Mono Nerd Font installed from the requested upstream archive.",
        "", "## Restore limitations", "",
        "REVIEW: Existing Terraform 1.5.7, third-party cross-compilers, Dagger and Packer",
        "are inventoried but require explicit version/tap-trust decisions on a fresh host.",
        "REVIEW: merve and nbytes do not record an explicit/dependency installation reason.",
        "The installer does not upgrade these tools, grant trust, or remove packages.", "",
    ])
    target = root / "docs/brew-inventory.md"
    target.write_text("\n".join(lines))
    print(f"Recorded {len(formulae)} formulae and {len(casks)} casks in {target}")


if __name__ == "__main__":
    main()
