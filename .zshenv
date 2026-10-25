# Keep noninteractive shells quiet; do not load prompts or integrations here.
typeset -U path
path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path)
