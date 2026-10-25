# Native Zsh + Starship. This repository owns portable shell configuration.
unset ZSH ZSH_THEME
typeset -U path fpath

# Interactive non-login shells also need Homebrew and user-installed binaries.
if (( ! $+commands[brew] )); then
  [[ ! -r "$HOME/.zprofile" ]] || source "$HOME/.zprofile"
fi
export GOPATH="${GOPATH:-$HOME/go}"
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
path=("$HOME/.local/bin" "$BUN_INSTALL/bin" "$HOME/.cargo/bin" "$GOPATH/bin" $path)
export EDITOR=nvim
export VISUAL=nvim
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt append_history share_history hist_ignore_dups hist_ignore_space

_dotfiles_brew_prefix=""
if (( $+commands[brew] )); then
  _dotfiles_brew_prefix="${HOMEBREW_PREFIX:-$(brew --prefix)}"
  fpath=("$_dotfiles_brew_prefix/share/zsh-completions" $fpath)
fi
autoload -Uz compinit
compinit -d "$HOME/.zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[-_.]=* r:|=*'
[[ ! -r "$BUN_INSTALL/_bun" ]] || source "$BUN_INSTALL/_bun"

alias -g G='| rg'
alias -g L='| less'
alias h=history
alias ll='ls -lah'
alias ..='cd ..'
alias myip='curl https://api.ipify.org; echo'
# ____________________ REVIEW ____________________
# This subnet matches the current home LAN; change it before using elsewhere.
alias lips='nmap -sn 192.168.1.0/24'
alias bup='brew upgrade'

alias g=git
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gcam='git commit --all --message'
alias gco='git checkout'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'
alias gst='git status'

(( ! $+commands[btop] )) || alias top=btop
if (( $+commands[bat] )); then
  alias cat=bat
  alias rcat='/bin/cat'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT=-c
fi
(( ! $+commands[dust] )) || alias du=dust
# ____________________ REVIEW ____________________
# exa, bottom, fd, procs and broot aliases were removed. Native ls/find/ps/tree
# remain available; absent replacements are not installed automatically.
if (( $+commands[podman] )); then
  alias docker=podman
  alias pdcl='podman image prune -a'
fi
# REVIEW: The old dkc alias mixed sudo/docker and parsed human-readable output.
# It remains in reference/initial-dotfiles; use podman container prune deliberately.

# Host-specific endpoints belong to the ignored local directory in dotfiles.
[[ ! -r "$HOME/.zshrc.local" ]] || source "$HOME/.zshrc.local"
if [[ ${TERM:-dumb} != dumb ]] && (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
if [[ -n "$_dotfiles_brew_prefix" ]]; then
  [[ ! -r "$_dotfiles_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] ||
    source "$_dotfiles_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  # Syntax highlighting is the last interactive plugin loaded.
  [[ ! -r "$_dotfiles_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] ||
    source "$_dotfiles_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
unset _dotfiles_brew_prefix

# Bypass once with HERDR_AUTO_START=0 zsh; never attach from scripts or nested panes.
if [[ -o interactive && -t 0 && -t 1 && -z ${HERDR_ENV:-} && ${HERDR_AUTO_START:-1} != 0 ]] && (( $+commands[herdr] )); then
  exec herdr
fi
