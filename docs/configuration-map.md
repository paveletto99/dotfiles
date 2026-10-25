# Managed configuration

Every Brewfile tool not listed below uses its upstream defaults or
project-specific configuration. Transitive dependencies require no dotfiles.
The complete installed package list is in [brew-inventory.md](brew-inventory.md).

| Tool | Authoritative source | Active destination / behavior |
| --- | --- | --- |
| Zsh | Root .zshenv, .zprofile, .zshrc | Individual links in the home directory; native completion and Homebrew plugins |
| Starship | .config/starship.toml | ~/.config/starship.toml |
| Git, delta | .gitconfig, .config/git/ignore | Global Git settings and global excludes, distinct from this repo's .gitignore |
| Ghostty | .config/ghostty/config.ghostty | XDG config; legacy/macOS override files backed up |
| Neovim | .config/nvim submodule | Whole config-directory link; submodule retains its own history and local changes |
| Zed | .config/zed/settings.json | ~/.config/zed/settings.json; custom theme directory currently empty |
| VS Code Insiders | .config/vscode/settings.json | Platform-specific User/settings.json |
| Herdr | .config/herdr/config.toml | Only static config; sockets, sessions, logs and generated Codex integration stay local |
| Codex | .codex/config.toml plus ignored local/codex.toml | Rendered ~/.codex/config.toml; --check compares parsed settings |
| Codex instructions | .codex/AGENTS.md | Individual home link |
| Custom skills | .agents/skills and .codex/skills | Individual skill-directory links; bundled/system/plugin skills stay local |
| ripgrep | .config/ripgrep/config | RIPGREP_CONFIG_PATH set in .zshrc |
| btop, htop | .config/btop/btop.conf, .config/htop/htoprc | Individual config links; upstream may rewrite preferences after interactive changes |
| Go, Rust, Bun, uv | .zshenv and .zshrc | Existing installation paths retained; runtime caches and downloaded toolchains stay local |
| Podman | .zshrc and ignored local/zshrc.local | Shared alias plus this Mac's Docker-compatible endpoint; native connection/machine/identity state stays local |
| Ioskeley font | scripts/install-ioskeley-font.py | User font directory plus release URL and file-digest receipt |
| age, sops | Existing local identity storage and project rules | Private keys remain in place; project .sops.yaml files belong to their projects |
| Packer, Terraform, Ansible | Their project repositories | Runtime caches and checkpoint state remain local; tool-source questions are marked REVIEW |

REVIEW: The imported custom cluster skill's
`.codex/skills/manage-rk1-home-cluster/references/cluster-reference.md` contains
existing machine paths. Review those references when using the skill elsewhere.
No cluster provisioning or infrastructure changes are performed by dotfiles.

SSH configuration, credentials, NATS contexts, Podman machine state, histories,
editor conversations, auth stores, plugin caches and private age identities are
deliberately outside managed configuration. Historical SSH/editor work settings
from home-lab remain inactive under reference/ for manual review.
