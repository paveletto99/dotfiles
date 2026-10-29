# Native Zsh + Starship; portable settings belong in this repository.

# --- PATH and language runtimes ------------------------------------------------

# This works with the macOS and Linux installers without hardcoding /opt/homebrew.
unset ZSH ZSH_THEME
typeset -U path fpath
if (( ! $+commands[brew] )); then
  [[ ! -r "$HOME/.zprofile" ]] || source "$HOME/.zprofile"
fi
export GOPATH="${GOPATH:-$HOME/go}"
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
path=("$HOME/.local/bin" "$BUN_INSTALL/bin" "$HOME/.cargo/bin" "$GOPATH/bin" $path)


# NVM if projects require different Node versions; choose one owner.
export NVM_DIR="$HOME/.nvm"
[[ ! -s "$NVM_DIR/nvm.sh" ]] || source "$NVM_DIR/nvm.sh"
[[ ! -s "$NVM_DIR/bash_completion" ]] || source "$NVM_DIR/bash_completion"

# --- Editor and command-line editing ------------------------------------------
# Neovim matches your submodule and works in terminal/SSH sessions.
export EDITOR=nvim
export VISUAL=nvim
# macOS Zed Preview. Replace the two editor exports above if enabled.
if [[ $OSTYPE == darwin* && -x "/Applications/Zed Preview.app/Contents/MacOS/cli" ]]; then
  zed() { command "/Applications/Zed Preview.app/Contents/MacOS/cli" "$@"; }
  export EDITOR='"/Applications/Zed Preview.app/Contents/MacOS/cli" --wait'
  export VISUAL="$EDITOR"
fi

# Editing mode. The current default resolves to viins with EDITOR=nvim.
# vi mode fits your Neovim usage; an explicit binding is optional.
bindkey -v
KEYTIMEOUT=10

# --- Native history and completion --------------------------------------------
# RECOMMENDED: retain native history until you choose an additional history backend.
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

# Keep disabled until you choose its Ctrl-T / Alt-C / Ctrl-R bindings.
if (( $+commands[fzf] )); then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
  # Optional incoming preview; bat must be installed before choosing it.
  export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || ls -la {}"'
  export FZF_ALT_C_OPTS='--preview "ls -la {}"'
  source <(fzf --zsh)
fi

# If choosing both, initialize Atuin AFTER fzf so Atuin owns Ctrl-R.
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh)"
fi
# Sources: https://github.com/junegunn/fzf#setting-up-shell-integration
#          https://github.com/atuinsh/atuin

# --- Navigation and search ----------------------------------------------------
# RECOMMENDED: keep native cd and one canonical ripgrep configuration.
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
alias ..='cd ..'
alias cd='cd -P'
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
# Source: https://github.com/ajeetdsouza/zoxide#installation

# --- Personal and Git shortcuts ----------------------------------------------
alias -g G='| rg'
alias -g L='| less'
alias h=history
alias ll='ls -lah'
alias myip='curl https://api.ipify.org; echo'
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
alias gpl='git pull'
alias gp='git push'
alias gst='git status'
alias glog='git --no-pager log --oneline --decorate -n 10'
alias gl='git --no-pager log --oneline --decorate -n 10'

# Optional nonconflicting incoming shortcuts; enable individually if useful.
alias zshconfig='$EDITOR ~/.zshrc'
alias lsa='ls -alh'
alias sl=ls
alias less='less -X'
alias unixts='date +%s'
alias iso8601="date -u +'%Y-%m-%dT%H:%M:%SZ'"
alias nv=nvim
alias codexr='codex resume'
alias codexa='codex resume --last'
alias oc='opencode --continue'
alias ocr='opencode run'
alias ocs='opencode "$HOME/Workspace/scratch"'
alias k=kubectl
alias kgs='kubectl get svc -A -o wide'
alias kgp='kubectl get pod -A --show-labels'
# RECOMMENDED Python shorthand: follow the installed Python rather than pinning 3.8.
alias py=python3
# ALTERNATIVE: only if this legacy interpreter is deliberately installed.
# alias py=python3.8

# --- Command replacements and containers --------------------------------------
# RECOMMENDED: btop is installed/configured; retain it as your top replacement.
(( ! $+commands[btop] )) || alias top=btop

# RECOMMENDED: retain your bat/dust shortcuts, with rcat for native cat behavior.
if (( $+commands[bat] )); then
  alias cat=bat
  alias rcat='/bin/cat'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT=-c
fi
(( ! $+commands[dust] )) || alias du=dust

# REVIEW: native ls/find/ps/tree versus incoming replacements.
# RECOMMENDED: preserve native command names; use separate shortcuts for new tools.
# alias ff=fd
# ALTERNATIVE: global replacements change flags/output; choose each deliberately.
# alias ls=exa
# alias find=fd
# alias ps=procs
# alias tree=broot
# ALTERNATIVE process search shortcut; this is grep-based, not an exact PID lookup.
# alias pid='ps -A -e -l | grep'

# Podman matches Brewfile and your current VM/connection setup.
if (( $+commands[podman] )); then
  alias docker=podman
  alias pdcl='podman image prune -a'
fi
# ALTERNATIVE: a real Docker CLI/runtime; remove the alias above if you choose it.
# unalias docker
# Optional incoming container shortcuts, aligned explicitly with Podman.
# alias pd=podman
# alias pdi='podman images -a'
# alias pdc='podman ps -a'
# REVIEW: the incoming dkc pipeline parsed docker ps text and mixed sudo/root state.
# RECOMMENDED replacement for that intent: explicit Podman pruning when desired.
# alias dkc='podman container prune'
# NOT RECOMMENDED incoming pipeline; retained for comparison, never run at startup.
# alias dkc="sudo docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm"
# REVIEW: retain Kubernetes' selected context instead of forcing a single kind file.
# ALTERNATIVE: a host-specific kubeconfig, preferably in ~/.zshrc.local.
# export KUBECONFIG="$HOME/.kube/kind-kubernetes-clusters-cluster-dev01.kubeconfig"

# --- Optional incoming development helpers ------------------------------------
# These are disabled choices, not additional startup dependencies.
# alias gtvc='go test -v -race -cover .'
# alias coverhtml='go test -coverprofile=coverage.out && go tool cover -html=coverage.out -o coverage.html'
# sloc() { command find . -type f -name '*.go' -print0 | xargs -0 wc -l; }
# The incoming godoc helpers require a separately installed godoc executable.
# alias todo='godoc -notes="TODO" .'
# alias godoc-this='godoc -http=:6060'
# Open http://localhost:6060/pkg separately; the original sequential alias blocked.
# env-update() { exec zsh; }
# mins-ago() { print -r -- "$(( $(date +%s) - 60 * ${1:-0} ))"; }
# hours-ago() { print -r -- "$(( $(date +%s) - 3600 * ${1:-0} ))"; }
# yesterday() { print -r -- "$(( $(date +%s) - 86400 ))"; }
# time-at() {
#   if [[ $OSTYPE == darwin* ]]; then
#     command date -r "$1"
#   else
#     command date -d "@$1"
#   fi
# }
# REVIEW: native lazygit is simpler; use this opt-in helper only if you want exit cd.
# The temporary file and command cat avoid the old shared-file/bat alias conflict.
# lg() {
#   local directory_file directory_name lazygit_status
#   directory_file="$(mktemp)" || return
#   LAZYGIT_NEW_DIR_FILE="$directory_file" command lazygit "$@"
#   lazygit_status=$?
#   if (( lazygit_status == 0 )) && [[ -s "$directory_file" ]]; then
#     directory_name="$(command cat -- "$directory_file")"
#     [[ ! -d "$directory_name" ]] || builtin cd -- "$directory_name"
#   fi
#   command rm -f -- "$directory_file"
#   return "$lazygit_status"
# }

# REVIEW: Incoming Linux administration aliases do not belong in macOS defaults.
if [[ $OSTYPE == linux* ]]; then
  alias i='sudo apt-get install -y'
  alias up='sudo apt-get update && sudo apt-get upgrade -y'
fi
# NOT RECOMMENDED: the incoming ownership wrapper is incomplete/broad; use an
# explicit chown command on a chosen path instead of enabling it as written.
alias my="'sudo chown -R $(id -u)'"
# ALTERNATIVE macOS DNS helper; it runs only when explicitly invoked, not on startup.
if [[ $OSTYPE == darwin* ]]; then
  flush-dns() {
    sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
  }
fi
# REVIEW: legacy airport/private-framework commands are host/version-specific.
# RECOMMENDED: leave this incoming MAC-changing helper disabled on this setup.
if [[ $OSTYPE == darwin* ]]; then
  alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'
  get_new_mac() {
    sudo /System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -z &&
      sudo ifconfig en0 ether "a0$(openssl rand -hex 5 | sed 's/\(.\{2\}\)/:\1/g')" &&
      networksetup -detectnewhardware
  }
fi
# REVIEW: keep warning suppression off unless you deliberately want this behavior.
# export NO_D1_WARNING=1
# Incoming keychain commands referred to another host/user's files; keep them off.
# /usr/bin/keychain --nogui "$HOME/.ssh/dev_debian_wsl_doit" > /dev/null 2>&1
# [[ ! -r "$HOME/.keychain/NBGIOVANNINI-sh" ]] || source "$HOME/.keychain/NBGIOVANNINI-sh"

# --- Host overrides, prompt and interactive plugins ----------------------------
# RECOMMENDED: keep machine endpoints outside portable config; one host override.
[[ ! -r "$HOME/.zshrc.local" ]] || source "$HOME/.zshrc.local"

# RECOMMENDED: Starship is already installed/configured and fits your current setup.
# https://starship.rs/guide/
if [[ ${TERM:-dumb} != dumb ]] && (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
# REVIEW: Prompt alternatives. Disable Starship before selecting another prompt.
# ALTERNATIVE: native Zsh prompt, minimal dependencies but no Git/runtime segments.
# PROMPT='%F{blue}%~%f %# '
# ALTERNATIVE: incoming Oh My Zsh themes, only if you want its framework/plugins.
# If chosen, also disable native compinit/standalone plugin loading to avoid doubles.
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME=robbyrussell
# plugins=(colored-man-pages command-not-found gem git github zsh-autosuggestions zsh-syntax-highlighting)
# zstyle ':omz:alpha:lib:git' async-prompt yes
# CASE_SENSITIVE=false
# HYPHEN_INSENSITIVE=true
# [[ ! -r "$ZSH/oh-my-zsh.sh" ]] || source "$ZSH/oh-my-zsh.sh"
# ALTERNATIVE within Oh My Zsh: use Powerlevel10k instead of robbyrussell.
# Set ZSH_THEME before sourcing Oh My Zsh, not after it.
# ZSH_THEME=powerlevel10k/powerlevel10k
# [[ ! -r "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
# Incoming Powerlevel10k instant-prompt optimization belongs at the TOP of this file
# if you choose that theme. It is not used with the active Starship setup.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
# Incoming kube-aliases/kubectl plugins are another optional OMZ plugin selection.
# plugins=(git zsh-autosuggestions kube-aliases kubectl)
# ALTERNATIVE custom OMZ prompt with the incoming vi-mode indicator.
# Use this only after OMZ supplies git_prompt_info/colors; do not mix with Starship.
# ZSH_THEME_GIT_PROMPT_PREFIX=' %F{208}('
# ZSH_THEME_GIT_PROMPT_SUFFIX=')%f'
# ZSH_THEME_GIT_PROMPT_DIRTY=' ✗'
# ZSH_THEME_GIT_PROMPT_CLEAN=' ✓'
# NEWLINE=$'\n'
# function zle-line-init zle-keymap-select {
#   case $KEYMAP in
#     vicmd) VI_MODE='%F{white}nrm%f' ;;
#     viins|main) VI_MODE='%F{yellow}ins%f' ;;
#   esac
#   zle reset-prompt
# }
# zle -N zle-line-init
# zle -N zle-keymap-select
# VI_MODE='%F{yellow}ins%f'
# export PROMPT='%F{green}%p%F{blue}%~$(git_prompt_info)%f${NEWLINE}${ret_status}${VI_MODE} ➜ '

# RECOMMENDED: keep these standalone plugins with native Zsh + Starship.
# Any optional fzf/Atuin/ZLE initialization must remain ABOVE syntax highlighting.
if [[ -n "$_dotfiles_brew_prefix" ]]; then
  [[ ! -r "$_dotfiles_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] ||
    source "$_dotfiles_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ ! -r "$_dotfiles_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] ||
    source "$_dotfiles_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
unset _dotfiles_brew_prefix

# --- Terminal manager: choose ONE automatic launcher ---------------------------
# RECOMMENDED: Herdr matches your current agent workflow; keep the active block.
# ALTERNATIVE: tmux if traditional terminal sessions matter more than Herdr's UI.
# Disable the Herdr block before enabling tmux; do not nest automatic launchers.
# if [[ -o interactive && -t 0 && -t 1 && -z ${TMUX:-} && ${TERM_PROGRAM:-} == ghostty ]] && (( $+commands[tmux] )); then
#   exec tmux new-session -A -s main
# fi
# ALTERNATIVE: Zellij if you prefer its terminal/pane workflow. Disable Herdr first.
# export ZELLIJ_CONFIG_DIR="$HOME/.config/zellij"
# if [[ -o interactive && -t 0 && -t 1 && -z ${ZELLIJ:-} ]] && (( $+commands[zellij] )); then
#   eval "$(zellij setup --generate-auto-start zsh)"
# fi
# Bypass the active launcher once with HERDR_AUTO_START=0 zsh.
if [[ -o interactive && -t 0 && -t 1 && -z ${HERDR_ENV:-} && ${HERDR_AUTO_START:-1} != 0 ]] && (( $+commands[herdr] )); then
  exec herdr
fi
