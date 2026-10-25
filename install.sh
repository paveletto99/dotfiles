#!/usr/bin/env bash
# Install the tools and explicit managed configuration from this checkout.
set -euo pipefail
install_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
mode=install
case "${1:-}" in
'') ;;
--dry-run) mode=dry-run ;;
--check) mode=check ;;
--link-only) mode=link-only ;;
--help)
  echo 'Usage: bash install.sh [--dry-run|--check|--link-only]'
  exit 0
  ;;
*)
  echo "Unknown option: $1" >&2
  exit 2
  ;;
esac
if (($# > 1)); then
  echo 'Expected at most one option.' >&2
  exit 2
fi

os="$(uname -s)"
architecture="$(uname -m)"
case "$os" in
Darwin) platform=darwin ;;
Linux)
  platform=linux
  if [[ "$architecture" != aarch64 && "$architecture" != arm64 ]]; then
    echo 'Supported Linux target: Debian/Ubuntu ARM64.' >&2
    exit 1
  fi
  if [[ ! -r /etc/os-release ]] || ! grep -Eq '^(ID|ID_LIKE)=.*(debian|ubuntu)' /etc/os-release; then
    echo 'Supported Linux target: Debian/Ubuntu ARM64.' >&2
    exit 1
  fi
  ;;
*)
  echo "Unsupported operating system: $os" >&2
  exit 1
  ;;
esac

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_BUNDLE_NO_UPGRADE=1
for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x "$brew_path" ]]; then
    eval "$("$brew_path" shellenv)"
    break
  fi
done

find_dotfiles_python() {
  local candidate
  for candidate in python3.14 python3.13 python3.12 python3.11 python3; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import tomllib' 2>/dev/null; then
      dotfiles_python="$(command -v "$candidate")"
      return
    fi
  done
  echo 'Python 3.11+ is required; install Python or run the full installer.' >&2
  return 1
}

if [[ "$mode" == dry-run ]]; then
  echo "Plan: bootstrap $os prerequisites; install missing Brewfile tools without blanket upgrades."
  echo 'Plan: initialize pinned submodules, install Ioskeley font, deploy managed configuration.'
  echo 'Plan: preserve existing Rust/Bun/Herdr; install from official sources only when missing.'
  find_dotfiles_python
  "$dotfiles_python" "$install_dir/scripts/manage-dotfiles.py" --mode dry-run --platform "$platform"
  exit 0
fi

if [[ "$mode" == install ]]; then
  if [[ "$platform" == linux ]]; then
    sudo apt-get update
    sudo apt-get install -y build-essential procps curl file git ca-certificates unzip python3 fontconfig podman podman-compose
  elif ! xcode-select -p >/dev/null 2>&1; then
    echo 'Install Apple Command Line Tools with xcode-select --install, then rerun.' >&2
    exit 1
  fi
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ "$platform" == linux ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ "$architecture" == arm64 ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
  brew bundle install --no-upgrade --file="$install_dir/Brewfile"
  git -C "$install_dir" submodule update --init --recursive
  if ! command -v rustc >/dev/null 2>&1 && [[ ! -x "$HOME/.cargo/bin/rustc" ]]; then
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi
  if ! command -v bun >/dev/null 2>&1 && [[ ! -x "$HOME/.bun/bin/bun" ]]; then
    # Install the official release binary without letting an installer edit .zshrc.
    if [[ "$platform" == linux ]]; then
      bun_target=linux-aarch64
    elif [[ "$architecture" == arm64 ]]; then
      bun_target=darwin-aarch64
    else
      bun_target=darwin-x64
    fi
    bun_temporary="$(mktemp -d)"
    trap 'rm -rf "$bun_temporary"' EXIT
    curl -fsSL "https://github.com/oven-sh/bun/releases/latest/download/bun-$bun_target.zip" -o "$bun_temporary/bun.zip"
    unzip -q "$bun_temporary/bun.zip" "bun-$bun_target/bun" -d "$bun_temporary"
    mkdir -p "$HOME/.bun/bin"
    install -m 755 "$bun_temporary/bun-$bun_target/bun" "$HOME/.bun/bin/bun"
    rm -rf "$bun_temporary"
    trap - EXIT
  fi
  if ! command -v herdr >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/herdr" ]]; then
    curl -fsSL https://herdr.dev/install.sh | sh
  fi
  if [[ "$platform" == linux ]] && ! command -v codex >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/codex" ]]; then
    npm install --global --prefix "$HOME/.local" --registry https://registry.npmjs.org @openai/codex
  fi
fi

find_dotfiles_python
if [[ "$mode" == check ]]; then
  result=0
  "$dotfiles_python" "$install_dir/scripts/manage-dotfiles.py" --mode check --platform "$platform" || result=1
  "$dotfiles_python" "$install_dir/scripts/install-ioskeley-font.py" --check --platform "$platform" || result=1
  if command -v brew >/dev/null 2>&1; then
    brew bundle check --file="$install_dir/Brewfile" || result=1
  else
    echo 'Homebrew is missing.' >&2
    result=1
  fi
  submodule_state="$(git -C "$install_dir" submodule status --recursive)"
  printf '%s\n' "$submodule_state"
  if printf '%s\n' "$submodule_state" | grep -Eq '^[-+U]'; then
    echo 'Submodules are missing or differ from the recorded revision.' >&2
    result=1
  fi
  for required_tool in rustc bun herdr codex; do
    if ! command -v "$required_tool" >/dev/null 2>&1 &&
      [[ ! -x "$HOME/.local/bin/$required_tool" && ! -x "$HOME/.cargo/bin/$required_tool" && ! -x "$HOME/.bun/bin/$required_tool" ]]; then
      echo "Required external tool is missing: $required_tool" >&2
      result=1
    fi
  done
  exit "$result"
fi
if [[ "$mode" == install ]]; then
  "$dotfiles_python" "$install_dir/scripts/install-ioskeley-font.py" --platform "$platform"
fi
"$dotfiles_python" "$install_dir/scripts/manage-dotfiles.py" --mode apply --platform "$platform"
echo 'Dotfiles installed. Open a new shell; use HERDR_AUTO_START=0 zsh to bypass Herdr.'
