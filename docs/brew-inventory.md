# Homebrew inventory

Generated 2026-10-25 by `python3 scripts/inventory-homebrew.py`.
Observed installed state, including dependencies; presence does not establish active use.
`Brewfile` defines the intended managed tools. REVIEW entries remain manual decisions.

## Taps

- `dagger/tap`
- `filosottile/musl-cross`
- `hashicorp/tap`
- `messense/macos-cross-toolchains`

## Formulae

| Formula | Installed version | Origin | Installation reason |
| --- | --- | --- | --- |
| `aarch64-unknown-linux-gnu` | `15.2.0` | `messense/macos-cross-toolchains` | Explicit |
| `aarch64-unknown-linux-musl` | `15.2.0` | `messense/macos-cross-toolchains` | Explicit |
| `abseil` | `20260817.0` | `homebrew/core` | REVIEW: not recorded |
| `ada-url` | `4.0.0` | `homebrew/core` | REVIEW: not recorded |
| `age` | `1.3.2` | `homebrew/core` | Explicit |
| `ansible` | `14.4.0_1` | `homebrew/core` | Explicit |
| `arp-scan` | `1.10.0` | `homebrew/core` | Explicit |
| `bat` | `0.26.1` | `homebrew/core` | Explicit |
| `biome` | `2.5.15` | `homebrew/core` | Explicit |
| `brotli` | `1.2.0` | `homebrew/core` | Dependency |
| `btop` | `1.4.7` | `homebrew/core` | Explicit |
| `c-ares` | `1.34.8` | `homebrew/core` | REVIEW: not recorded |
| `ca-certificates` | `2026-09-25` | `homebrew/core` | REVIEW: not recorded |
| `ca-certificates` | `2026-10-20` | `homebrew/core` | REVIEW: not recorded |
| `certifi` | `2026.7.22` | `homebrew/core` | REVIEW: not recorded |
| `cffi` | `2.1.1` | `homebrew/core` | REVIEW: not recorded |
| `cryptography` | `50.0.2` | `homebrew/core` | REVIEW: not recorded |
| `curl` | `8.22.0` | `homebrew/core` | Explicit |
| `dagger` | `0.20.3` | `dagger/tap` | Explicit |
| `dav1d` | `1.5.4` | `homebrew/core` | REVIEW: not recorded |
| `dust` | `1.2.6` | `homebrew/core` | Explicit |
| `espeak-ng` | `1.52.0` | `homebrew/core` | Explicit |
| `fastfetch` | `2.69.0` | `homebrew/core` | Explicit |
| `ffmpeg` | `9.0.2` | `homebrew/core` | Explicit |
| `fmt` | `12.2.0` | `homebrew/core` | REVIEW: not recorded |
| `gcc` | `16.2.0` | `homebrew/core` | Explicit |
| `gettext` | `1.0` | `homebrew/core` | Dependency |
| `git` | `2.56.0` | `homebrew/core` | Explicit |
| `git-delta` | `0.20.1` | `homebrew/core` | Explicit |
| `gmp` | `6.3.0` | `homebrew/core` | Dependency |
| `go` | `1.27.1` | `homebrew/core` | Explicit |
| `hdrhistogram_c` | `0.12.0` | `homebrew/core` | REVIEW: not recorded |
| `highway` | `1.4.0` | `homebrew/core` | REVIEW: not recorded |
| `htop` | `3.5.3` | `homebrew/core` | Explicit |
| `icu4c@78` | `78.3` | `homebrew/core` | Dependency |
| `isl` | `0.28` | `homebrew/core` | REVIEW: not recorded |
| `json-c` | `0.19` | `homebrew/core` | REVIEW: not recorded |
| `kubernetes-cli` | `1.37.1` | `homebrew/core` | Explicit |
| `lame` | `4.0` | `homebrew/core` | REVIEW: not recorded |
| `lazydocker` | `0.25.2` | `homebrew/core` | Explicit |
| `lazygit` | `0.66.0` | `homebrew/core` | Explicit |
| `lefthook` | `2.1.17` | `homebrew/core` | Explicit |
| `libffi` | `3.8.0` | `homebrew/core` | REVIEW: not recorded |
| `libgit2` | `1.9.7` | `homebrew/core` | REVIEW: not recorded |
| `liblinear` | `2.50` | `homebrew/core` | Dependency |
| `libmpc` | `1.4.1` | `homebrew/core` | REVIEW: not recorded |
| `libnghttp2` | `1.70.0` | `homebrew/core` | REVIEW: not recorded |
| `libnghttp3` | `1.18.0` | `homebrew/core` | REVIEW: not recorded |
| `libngtcp2` | `1.25.0` | `homebrew/core` | REVIEW: not recorded |
| `libpsl` | `0.23.3` | `homebrew/core` | REVIEW: not recorded |
| `libsodium` | `1.0.22` | `homebrew/core` | REVIEW: not recorded |
| `libssh` | `0.12.2` | `homebrew/core` | REVIEW: not recorded |
| `libssh2` | `1.11.1_6` | `homebrew/core` | REVIEW: not recorded |
| `libunistring` | `1.4.2` | `homebrew/core` | Dependency |
| `libuv` | `1.53.0` | `homebrew/core` | REVIEW: not recorded |
| `libvmaf` | `3.2.1` | `homebrew/core` | REVIEW: not recorded |
| `libvpx` | `1.17.0` | `homebrew/core` | REVIEW: not recorded |
| `libyaml` | `0.2.5` | `homebrew/core` | Dependency |
| `lima` | `2.2.1` | `homebrew/core` | Explicit |
| `llhttp` | `9.4.3` | `homebrew/core` | REVIEW: not recorded |
| `llvm` | `23.1.2` | `homebrew/core` | Explicit |
| `lpeg` | `1.1.0_2` | `homebrew/core` | Dependency |
| `lua` | `5.5.1` | `homebrew/core` | REVIEW: not recorded |
| `luajit` | `2.1.1788856981` | `homebrew/core` | REVIEW: not recorded |
| `luv` | `1.53.0-0` | `homebrew/core` | REVIEW: not recorded |
| `lz4` | `1.10.0` | `homebrew/core` | Dependency |
| `merve` | `1.2.2_3` | `homebrew/core` | REVIEW: not recorded |
| `mpdecimal` | `4.0.1` | `homebrew/core` | Dependency |
| `mpfr` | `4.2.2` | `homebrew/core` | Dependency |
| `mpg123` | `1.33.7` | `homebrew/core` | REVIEW: not recorded |
| `musl-cross` | `0.9.11` | `filosottile/musl-cross` | Explicit |
| `nbytes` | `0.1.4` | `homebrew/core` | REVIEW: not recorded |
| `ncurses` | `6.6` | `homebrew/core` | Dependency |
| `neovim` | `0.12.5_1` | `homebrew/core` | Explicit |
| `ninja` | `1.13.2` | `homebrew/core` | Explicit |
| `nmap` | `7.991` | `homebrew/core` | Explicit |
| `node` | `26.10.0_2` | `homebrew/core` | Explicit |
| `oniguruma` | `6.9.10` | `homebrew/core` | Dependency |
| `openssl@3` | `3.6.5` | `homebrew/core` | Explicit |
| `openssl@4` | `4.1.0` | `homebrew/core` | REVIEW: not recorded |
| `openssl@4` | `4.0.3` | `homebrew/core` | REVIEW: not recorded |
| `opus` | `1.6.1` | `homebrew/core` | Dependency |
| `packer` | `1.15.0` | `hashicorp/tap` | Explicit |
| `pcaudiolib` | `1.3` | `homebrew/core` | Dependency |
| `pcre2` | `10.49` | `homebrew/core` | REVIEW: not recorded |
| `pkgconf` | `3.0.7` | `homebrew/core` | Explicit |
| `podman` | `6.1.3` | `homebrew/core` | Explicit |
| `podman-compose` | `1.6.0` | `homebrew/core` | Explicit |
| `pycparser` | `3.0` | `homebrew/core` | Dependency |
| `python@3.14` | `3.14.8` | `homebrew/core` | Explicit |
| `readline` | `8.3.6` | `homebrew/core` | REVIEW: not recorded |
| `ripgrep` | `15.2.0` | `homebrew/core` | Explicit |
| `sdl2-compat` | `2.32.74` | `homebrew/core` | REVIEW: not recorded |
| `sdl3` | `3.4.18` | `homebrew/core` | REVIEW: not recorded |
| `shellcheck` | `0.11.0` | `homebrew/core` | Explicit |
| `shfmt` | `3.14.1` | `homebrew/core` | Explicit |
| `simdjson` | `5.0.2` | `homebrew/core` | REVIEW: not recorded |
| `simdutf` | `9.2.1_1` | `homebrew/core` | REVIEW: not recorded |
| `socat` | `1.8.1.3` | `homebrew/core` | Explicit |
| `sops` | `3.13.3` | `homebrew/core` | Explicit |
| `sqlite` | `3.53.4` | `homebrew/core` | REVIEW: not recorded |
| `starship` | `1.26.0` | `homebrew/core` | Explicit |
| `svt-av1` | `4.2.0` | `homebrew/core` | REVIEW: not recorded |
| `terraform` | `1.5.7` | `homebrew/core` | Explicit |
| `tflint` | `0.61.0` | `homebrew/core` | Explicit |
| `tree` | `2.3.2` | `homebrew/core` | Explicit |
| `tree-sitter` | `0.27.0` | `homebrew/core` | Explicit |
| `tree-sitter-cli` | `0.27.0` | `homebrew/core` | Explicit |
| `unibilium` | `2.1.4` | `homebrew/core` | REVIEW: not recorded |
| `utf8proc` | `2.12.0` | `homebrew/core` | REVIEW: not recorded |
| `uv` | `0.12.23` | `homebrew/core` | Explicit |
| `uvwasi` | `0.0.23` | `homebrew/core` | Dependency |
| `wrk` | `4.2.0_2` | `homebrew/core` | Explicit |
| `x264` | `r3222` | `homebrew/core` | Dependency |
| `x265` | `4.3` | `homebrew/core` | REVIEW: not recorded |
| `xz` | `5.8.4` | `homebrew/core` | REVIEW: not recorded |
| `yaml-language-server` | `1.24.0` | `homebrew/core` | Explicit |
| `yyjson` | `0.13.0` | `homebrew/core` | REVIEW: not recorded |
| `z3` | `5.1.0` | `homebrew/core` | REVIEW: not recorded |
| `zsh-autosuggestions` | `0.7.1` | `homebrew/core` | Explicit |
| `zsh-completions` | `0.36.0` | `homebrew/core` | Explicit |
| `zsh-syntax-highlighting` | `0.8.0` | `homebrew/core` | Explicit |
| `zstd` | `1.5.7_1` | `homebrew/core` | Dependency |

## Casks

| Cask | Installed version |
| --- | --- |
| `codex` | `0.164.0` |
| `font-departure-mono-nerd-font` | `3.5.1` |

## Tools installed outside Homebrew

- macOS system Zsh; Apple Command Line Tools.
- Rust via rustup, Cargo-installed exa (its shell alias is now inactive).
- Bun in `~/.bun`; Herdr in `~/.local/bin`.
- Ghostty, Zed Preview and VS Code Insiders installed as macOS applications.
- Ioskeley Mono Nerd Font installed from the requested upstream archive.

## Restore limitations

REVIEW: Existing Terraform 1.5.7, third-party cross-compilers, Dagger and Packer
are inventoried but require explicit version/tap-trust decisions on a fresh host.
REVIEW: merve and nbytes do not record an explicit/dependency installation reason.
The installer does not upgrade these tools, grant trust, or remove packages.
