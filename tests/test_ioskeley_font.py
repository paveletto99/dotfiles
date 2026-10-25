"""Verify font metadata reading and detection of missing/corrupted installed faces."""

import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("font", ROOT / "scripts/install-ioskeley-font.py")
FONT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(FONT)


class IoskeleyFontTests(unittest.TestCase):
    def test_reads_actual_family_instead_of_guessing_from_archive_name(self):
        family = "IoskeleyMono Nerd Font".encode("utf-16-be")
        # Minimal SFNT fixture with one Windows English name-table record.
        header = struct.pack(">IHHHH", 0x10000, 1, 16, 0, 0)
        table = struct.pack(">HHH", 0, 1, 18)
        table += struct.pack(">HHHHHH", 3, 1, 1033, 16, len(family), 0) + family
        record = struct.pack(">4sIII", b"name", 0, 28, len(table))
        self.assertEqual(FONT.font_family_name(header + record + table), "IoskeleyMono Nerd Font")

    def test_font_receipt_detects_corruption_and_missing_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            self.assertFalse(FONT.installed_font_status(directory))
            face = directory / "regular.ttf"
            face.write_bytes(b"font fixture")
            (directory / "installed.json").write_text(json.dumps({
                "url": FONT.FONT_URL,
                "files": {face.name: hashlib.sha256(face.read_bytes()).hexdigest()},
            }))
            self.assertTrue(FONT.installed_font_status(directory))
            face.write_bytes(b"changed")
            self.assertFalse(FONT.installed_font_status(directory))
            face.unlink()
            self.assertFalse(FONT.installed_font_status(directory))


if __name__ == "__main__":
    unittest.main()
