# Package source of truth; docs/brew-inventory.md records observed installations.
# Rust, Bun, Herdr and the Ioskeley font are handled once by install.sh.

# Shell, navigation, search and terminal utilities.
%w[
  asciinema atuin bat btop direnv dust fastfetch fd fzf gh git git-delta htop
  jq just ripgrep starship tealdeer tree try wget yq zoxide
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

tap "plannotator/tap"

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
end