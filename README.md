# dotfiles

The source of truth for Paolo's development configuration: native Zsh + Starship,
Ghostty, Neovim, Zed, VS Code Insiders, Git, Herdr, Codex and CLI tools.

The live Mac settings supplied the initial configuration. Future conflicts are
resolved by editing this repository, then redeploying it. Machine-specific
exceptions live in ignored `local/` files; credentials remain in existing storage.

## Install

Use a complete checkout, normally `~/Workspace/dotfiles`. The scripts also work
from another directory, including paths containing spaces. On fresh machines:

```sh
git clone --recurse-submodules https://github.com/paveletto99/dotfiles.git ~/Workspace/dotfiles
cd ~/Workspace/dotfiles
bash install.sh --dry-run
bash install.sh
```

macOS needs Apple Command Line Tools. Debian/Ubuntu Linux is supported on ARM64;
use a current distro (Debian 12+ or Ubuntu 22.04+) compatible with Homebrew.
Linux setup installs system prerequisites, fontconfig and native Podman via APT;
shared CLI tools come from Linuxbrew. It does not start container services.
macOS applications are installed only if their existing app bundles are absent.
GUI editor installation on Linux is manual; their configuration is still managed.

The installer installs missing packages without requesting blanket upgrades,
initializes pinned submodules, installs the font and deploys explicit file links.
It does not change the login shell, create SSH keys, configure signing, provision
APFS volumes, alter macOS preferences or remove other packages.

```sh
bash install.sh --dry-run    # Show proposed deployment; change nothing
bash install.sh --check      # Detect configuration, package, font or submodule drift
bash install.sh --link-only  # Deploy configuration without installing tools/fonts
```

Dry-run, check and link-only require Python 3.11+ (the full installer installs it).
Rerunning a matching deployment does not create more backups. `--check` accepts
uncommitted Neovim files when its checked-out commit still matches the gitlink.
It intentionally reports a different submodule commit as drift.

## Configuration layout and precedence

- Root `.zshenv`, `.zprofile`, `.zshrc`, `.gitconfig`: shared shell/Git settings.
- `.config/`: terminal, editors, prompt, monitor and search configuration.
- `.config/nvim`: submodule of [vim-setup](https://github.com/paveletto99/vim-setup).
- `.agents/skills`, `.codex/skills`: live custom skills, linked individually.
- `.codex/AGENTS.md`, `.codex/config.toml`: shared Codex instructions/preferences.
- `local/`: ignored host settings, loaded after the shared configuration.
- `Brewfile`: intended package installation; `docs/brew-inventory.md`: complete
  observed package/version inventory, including dependencies and external tools.
- `reference/`: inactive original repo and historical home-lab files. Nothing here
  is deployed or executed by the installer.

Shell configuration retains existing history, completion, Git shortcuts, bat,
dust, autosuggestions and syntax highlighting. `top` uses installed btop. Native
`ls`, `find`, `ps` and `tree` replace the previous broken replacement aliases.
Starship remains the sole prompt provider; Oh My Zsh and Powerlevel10k are inactive.
Homebrew's prefix is discovered, and PATH entries are deduplicated without
replacing the inherited PATH. Native macOS Zsh is retained; Linuxbrew supplies Zsh
on Linux. Select a login shell manually if the machine still defaults to Bash.

Herdr attaches only from top-level interactive terminals with a TTY. Bypass it:

```sh
HERDR_AUTO_START=0 zsh
```

Ghostty loads the single managed XDG configuration. Deployment backs up its
legacy XDG file and macOS-specific override files so they cannot override the
repository's settings. Editor themes and font sizes retain the live choices.

Codex is an explicit exception to symlink deployment: the active
`~/.codex/config.toml` is rendered from the portable file plus ignored
`local/codex.toml`, with host settings taking precedence. Desktop integration
paths, project trust, marketplace configuration and runtime preferences remain
host-specific. Its parsed contents are checked against the sources on reruns.
Reconcile changes made through the app into those sources before redeploying.
Credentials, sessions, bundled plugins/system skills and Herdr-generated hooks
remain local. The migration preserves the current model and permission settings.

## Font

The installer uses the requested upstream archive:
[IoskeleyMono-NerdFont.zip](https://github.com/ahatem/IoskeleyMono/releases/latest/download/IoskeleyMono-NerdFont.zip).
It installs Normal-width NF faces, excluding SemiCondensed and NFM, under
`~/Library/Fonts/IoskeleyMono` on macOS or
`~/.local/share/fonts/IoskeleyMono` on Linux. Linux refreshes fontconfig.

The actual family in the downloaded archive is `IoskeleyMono Nerd Font`; Ghostty,
Zed and VS Code use that name. Each installation records the resolved release URL,
archive SHA-256 and installed file digests in the font directory's `installed.json`.
Matching reruns use no network. The archive cache in `.cache/` is ignored.

REVIEW: The current archive has no separate Hinted/Unhinted folders, despite the
[website](https://ahatem.github.io/IoskeleyMono/) describing them. Its bundled
faces are installed. If future archives provide them, macOS selects Unhinted
and Linux selects Hinted. Font updates are deliberate: back up the owned font
directory and remove the cached archive before rerunning. Existing conflicting
font files are never silently overwritten. Restart applications after installing.

## Neovim and updates

The submodule records commit `cdc16705b3dd07d0f40d28feb67aa299869b3ac5` at migration.
The existing modified `lazy-lock.json` and untracked `version` file were retained
in its working directory. They remain uncommitted and are not reproducible from
a fresh clone until you choose to commit them in vim-setup.

After pulling dotfiles, initialize the recorded submodule revision:

```sh
git submodule update --init --recursive
bash install.sh --check
bash install.sh
```

Inspect and preserve dirty submodule files before deliberately updating its
revision. The installer never uses `--force`, resets, commits or pushes.
To upgrade packages, run `brew upgrade` deliberately; installation is not an
upgrade command. Refresh the complete observed inventory afterward:

```sh
python3 scripts/inventory-homebrew.py
```

## Backups and manual review

Conflicting managed files move into
`~/.local/state/dotfiles/backups/<timestamp>/`, with their relative paths preserved.
`manifest.json` records each original location and backup. Existing symlinks are
backed up as symlinks; unrelated directories and runtime files remain in place.
The deployment stops before changes if a managed parent directory is itself a
symlink, so another checkout cannot be changed indirectly.

To restore a file, locate it in the manifest, inspect both versions, remove only
the corresponding managed symlink (or move the generated Codex file aside), and
move its saved original back to the recorded target. New files without a previous
version have no backup; remove their repository symlink if undoing deployment.
Never restore an entire `.codex` or `.config` directory over live runtime state.

[Review notes](docs/review.md) list outstanding choices. Search active files for
`REVIEW:` to find marked sections. The [configuration map](docs/configuration-map.md)
lists managed sources, local exceptions and tools that use upstream defaults.
Original repo content is preserved under
`reference/initial-dotfiles`, and the former `home-lab/envs/dev-setup` lives under
`reference/home-lab-dev-setup`. Historical installers are not executable and must
not be run through Bash either. home-lab retains a migration pointer.

## Verification

```sh
bash -n install.sh
zsh -n .zshrc .zshenv .zprofile
shellcheck install.sh
shfmt -d -i 2 install.sh
python3 -m unittest discover -s tests
bash install.sh --check
```

Tests use temporary homes and fixture configuration, including paths with spaces;
they never run package managers or modify the real home. Native Linux execution
requires verification on a Debian/Ubuntu ARM64 machine; tests of deployment paths
do not establish native package or GUI compatibility.
