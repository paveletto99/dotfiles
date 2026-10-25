# Package source of truth. Installed versions/dependencies are in docs/brew-inventory.md.
# Shared tools: macOS and Debian/Ubuntu ARM64 with Linuxbrew.
%w[
  age ansible arp-scan bat biome btop curl dust espeak-ng fastfetch ffmpeg gcc
  git git-delta go htop kubernetes-cli lazydocker lazygit lefthook llvm neovim
  ninja nmap node openssl@3 pkgconf python@3.14 ripgrep shellcheck shfmt socat
  sops starship tflint tree tree-sitter tree-sitter-cli uv wrk yaml-language-server
  zsh-autosuggestions zsh-completions zsh-syntax-highlighting
].each { |name| brew name }

if OS.mac?
  brew "lima"
  brew "podman"
  brew "podman-compose"
  cask "codex"
  cask "font-departure-mono-nerd-font"
  # Existing manually installed applications retain their current channel/version.
  cask "ghostty" unless File.directory?("/Applications/Ghostty.app")
  cask "zed@preview" unless File.directory?("/Applications/Zed Preview.app")
  cask "visual-studio-code@insiders" unless File.directory?("/Applications/Visual Studio Code - Insiders.app")
else
  brew "zsh"
  # Native Podman, fontconfig and clipboard prerequisites are installed by APT.
end

# ____________________ REVIEW ____________________
# These installed tap tools need a deliberate trust/version decision on a fresh
# machine. They are preserved locally; no tap trust or replacement is automatic.
# tap "dagger/tap"
# brew "dagger/tap/dagger"
# tap "hashicorp/tap"
# brew "hashicorp/tap/packer"
# tap "messense/macos-cross-toolchains"
# brew "messense/macos-cross-toolchains/aarch64-unknown-linux-gnu" # macOS only
# brew "messense/macos-cross-toolchains/aarch64-unknown-linux-musl" # macOS only
# tap "filosottile/musl-cross"
# brew "filosottile/musl-cross/musl-cross" # macOS only
# Terraform 1.5.7 is installed from the former core recipe. Do not silently
# replace it with a newer HashiCorp release or OpenTofu.
# merve/nbytes were not marked explicitly installed; inspect the inventory.
# Missing inherited tools (Atuin/OpenCode/fzf/zoxide/etc.) remain inactive.
