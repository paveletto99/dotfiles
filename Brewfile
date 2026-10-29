# Package source of truth; docs/brew-inventory.md records observed installations.
# Rust, Bun, Herdr and the Ioskeley font are handled once by install.sh.

# Shell, navigation, search and terminal utilities.
%w[
  asciinema atuin bat btop direnv dust fastfetch fd fzf gh git git-delta htop
  jq just ripgrep starship tealdeer tree try wget yq zellij zoxide
  zsh-autosuggestions zsh-completions zsh-syntax-highlighting
].each { |name| brew name }

# Languages, build tools, formatters and language servers.
%w[
  ast-grep biome cmake gcc go lua lua-language-server luacheck llvm make neovim
  ninja node opencode openssl@3 pipx pkgconf pnpm python@3.14 ruff shellcheck
  shfmt tree-sitter tree-sitter-cli uv yaml-language-server yarn zig
].each { |name| brew name }

# Infrastructure, containers, networking and media.
%w[
  age agg ansible arp-scan curl dive espeak-ng ffmpeg gifski k9s kind
  kubernetes-cli lazydocker lazygit lefthook mkcert nmap socat sops trivy
  websocat wrk
].each { |name| brew name }

# REVIEW: These upstream taps require scoped trust on a fresh host. No trust is
# granted here; review each tap before running brew bundle install.
tap "dagger/tap"
tap "hashicorp/tap"
tap "plannotator/tap"
brew "dagger/tap/dagger"
brew "hashicorp/tap/packer"
brew "plannotator/tap/plannotator-tui"

# Keep the installed legacy core TFLint without installing a second binary.
# Current upstream packaging uses a tap cask on macOS and Go works on Linux.
legacy_tflint = File.executable?(File.join(ENV.fetch("HOMEBREW_PREFIX"), "bin", "tflint"))

if OS.mac?
  # macOS VM/container tooling; Linux uses native Podman from APT in install.sh.
  brew "lima"
  brew "podman"
  brew "podman-compose"

  # Cross-compilers run on macOS and target the ARM64 Linux home cluster.
  tap "messense/macos-cross-toolchains"
  tap "filosottile/musl-cross"
  brew "messense/macos-cross-toolchains/aarch64-unknown-linux-gnu"
  brew "messense/macos-cross-toolchains/aarch64-unknown-linux-musl"
  brew "filosottile/musl-cross/musl-cross"

  unless legacy_tflint
    tap "terraform-linters/tap"
    cask "terraform-linters/tap/tflint"
  end

  cask "codex"
  cask "font-departure-mono-nerd-font"
  cask "obs" unless File.directory?("/Applications/OBS.app")
  cask "raycast" unless File.directory?("/Applications/Raycast.app")
  # Preserve manually installed applications and their existing update channels.
  cask "ghostty" unless File.directory?("/Applications/Ghostty.app")
  cask "zed@preview" unless File.directory?("/Applications/Zed Preview.app")
  cask "visual-studio-code@insiders" unless File.directory?("/Applications/Visual Studio Code - Insiders.app")
else
  brew "zsh"
  go "github.com/terraform-linters/tflint" unless legacy_tflint
  # Native Podman/fontconfig and Codex CLI installation remain in install.sh.
end

# ____________________ REVIEW: Conflicting alternatives ____________________
# Podman is the selected container runtime; enable OrbStack only deliberately.
# cask "orbstack"
# The installed Terraform 1.5.7 came from a retired core recipe. Keep its version
# choice separate from Packer; uncomment only after choosing a migration target.
# brew "hashicorp/tap/terraform"
# merve/nbytes remain inventory-only: their intended use is not established.
