"""Behavior tests run without changing the real home or installing packages."""

import importlib.util
import json
import os
from pathlib import Path
import tempfile
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("dotfiles", ROOT / "scripts/manage-dotfiles.py")
DEPLOY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DEPLOY)


class DotfileDeploymentTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles test ")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name) / "repo with spaces"
        self.home = Path(self.temporary.name) / "home with spaces"
        self.root.mkdir()
        self.home.mkdir()
        for folder in (".agents/skills", ".codex/skills"):
            (self.root / folder).mkdir(parents=True)
        (self.root / ".agents/skills/custom").mkdir()
        (self.root / ".agents/skills/custom/SKILL.md").write_text("custom skill")
        (self.root / ".config/nvim").mkdir(parents=True)
        (self.root / ".config/nvim/init.lua").write_text("-- existing Neovim")
        (self.root / "local").mkdir()
        (self.root / "local/zshrc.local").write_text("# host")
        for source, _ in DEPLOY.managed_dotfile_links(self.root, "darwin"):
            path = self.root / source
            if not path.exists():
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("# fixture\n")
        (self.root / ".codex/config.toml").write_text('model = "test-model"\n[tui]\nstatus_line = ["current-dir"]\n')
        (self.root / "local/codex.toml").write_text('[projects."/host/path"]\ntrust_level = "trusted"\n')

    def deployment(self, mode="apply", platform="darwin"):
        return DEPLOY.DotfileDeployment(self.root, self.home, platform, mode)

    def test_backup_conflicts_preserve_runtime_and_repeat_without_changes(self):
        shell = self.home / ".zshrc"
        shell.write_text("original shell")
        runtime = self.home / ".codex/sessions/local-session"
        runtime.parent.mkdir(parents=True)
        runtime.write_text("runtime stays local")
        ghostty = self.home / "Library/Application Support/com.mitchellh.ghostty/config"
        ghostty.parent.mkdir(parents=True)
        ghostty.write_text("font-size = 16")
        existing_target = self.home / "original-gitconfig"
        existing_target.write_text("original Git")
        (self.home / ".gitconfig").symlink_to(existing_target)
        deployment = self.deployment()
        self.assertEqual(deployment.deploy(), 0)
        self.assertTrue(shell.is_symlink())
        self.assertEqual((deployment.backup_root / ".zshrc").read_text(), "original shell")
        self.assertTrue((deployment.backup_root / ".gitconfig").is_symlink())
        self.assertEqual(existing_target.read_text(), "original Git")
        self.assertFalse(ghostty.exists())
        self.assertEqual(runtime.read_text(), "runtime stays local")
        self.assertTrue((self.home / ".config/nvim").is_symlink())
        self.assertFalse((self.home / ".codex").is_symlink())
        settings = tomllib.loads((self.home / ".codex/config.toml").read_text())
        self.assertEqual(settings["projects"]["/host/path"]["trust_level"], "trusted")
        second = self.deployment()
        self.assertEqual(second.deploy(), 0)
        self.assertEqual(second.drift, [])
        self.assertIsNone(second.backup_root)
        self.assertEqual(self.deployment("check").deploy(), 0)
        self.assertEqual(os.stat(self.home / ".codex/config.toml").st_mode & 0o777, 0o600)

    def test_dry_run_and_check_never_write(self):
        original = self.home / ".zshrc"
        original.write_text("keep me")
        before = sorted(str(p) for p in self.home.rglob("*"))
        self.assertEqual(self.deployment("dry-run").deploy(), 0)
        self.assertEqual(self.deployment("check").deploy(), 1)
        self.assertEqual(original.read_text(), "keep me")
        self.assertEqual(sorted(str(p) for p in self.home.rglob("*")), before)

    def test_source_preflight_does_not_partially_deploy(self):
        (self.root / ".config/starship.toml").unlink()
        with self.assertRaisesRegex(ValueError, "source missing"):
            self.deployment().deploy()
        self.assertEqual(list(self.home.iterdir()), [])

    def test_symlink_parent_is_not_followed_into_another_checkout(self):
        elsewhere = Path(self.temporary.name) / "another checkout"
        elsewhere.mkdir()
        (self.home / ".config").symlink_to(elsewhere, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, "parent is a symlink"):
            self.deployment().deploy()
        self.assertEqual(list(elsewhere.iterdir()), [])
        self.assertFalse((self.home / ".zshrc").exists())

    def test_linux_uses_xdg_editor_location_and_preserves_mac_paths(self):
        links = DEPLOY.managed_dotfile_links(self.root, "linux")
        targets = [target for _, target in links]
        self.assertIn(".config/Code - Insiders/User/settings.json", targets)
        self.assertFalse(any(target.startswith("Library/") for target in targets))
        mac_file = self.home / "Library/Application Support/com.mitchellh.ghostty/config"
        mac_file.parent.mkdir(parents=True)
        mac_file.write_text("preserve unrelated platform")
        self.assertEqual(self.deployment(platform="linux").deploy(), 0)
        self.assertEqual(mac_file.read_text(), "preserve unrelated platform")

    def test_nested_host_overrides_toml_quotes_and_arrays_round_trip(self):
        settings = {"model": "test", "mcp_servers": {"server.with.dot": {
            "command": "/path with spaces/tool", "args": ["quote\"", "back\\slash"],
            "env": {"EXAMPLE": "line1\nline2"}, "enabled": True,
        }}, "array": [{"name": "item", "value": 4}]}
        rendered = DEPLOY.render_toml_settings(settings)
        self.assertEqual(tomllib.loads(rendered), settings)
        self.assertEqual(DEPLOY.merge_codex_settings({"tui": {"a": 1}}, {"tui": {"b": 2}}), {"tui": {"a": 1, "b": 2}})

    def test_backup_manifest_supports_restoring_original_file(self):
        target = self.home / ".zshrc"
        target.write_text("original")
        deployment = self.deployment()
        deployment.deploy()
        manifest = json.loads((deployment.backup_root / "manifest.json").read_text())
        operation = next(item for item in manifest if item["target"] == str(target))
        target.unlink()
        Path(operation["backup"]).rename(target)
        self.assertEqual(target.read_text(), "original")

    def test_imported_themes_and_shared_skill_assets_use_canonical_files(self):
        for relative in (".config/ghostty/themes/custom", ".codex/themes/custom.tmTheme"):
            theme = self.root / relative
            theme.parent.mkdir(parents=True, exist_ok=True)
            theme.write_text("theme fixture")
        shared = self.root / ".agents/assets/icon.svg"
        shared.parent.mkdir(parents=True)
        shared.write_text("shared asset")
        icon = self.root / ".agents/skills/custom/icon.svg"
        icon.symlink_to("../../assets/icon.svg")
        optional = self.root / ".config/atuin/config.toml"
        optional.parent.mkdir(parents=True)
        optional.write_text("# optional")
        self.assertEqual(self.deployment().deploy(), 0)
        self.assertEqual((self.home / ".agents/skills/custom/icon.svg").resolve(), shared.resolve())
        for relative in (".config/ghostty/themes/custom", ".codex/themes/custom.tmTheme"):
            self.assertTrue((self.home / relative).is_symlink())
            self.assertEqual((self.home / relative).resolve(), (self.root / relative).resolve())
        self.assertFalse((self.home / ".config/atuin").exists())
        self.assertEqual(self.deployment("check").deploy(), 0)


if __name__ == "__main__":
    unittest.main()
