# Initialize the platform's Homebrew installation without changing system settings.
for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x "$brew_path" ]]; then
    eval "$("$brew_path" shellenv)"
    break
  fi
done
unset brew_path

# macOS login-only operations (run once per session, not every shell)
if [ "$(uname -s)" = "Darwin" ]; then
	ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github 2>/dev/null
	defaults write com.apple.screencapture target clipboard 2>/dev/null
fi
