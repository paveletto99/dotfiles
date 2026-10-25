# Host configuration

Files here are ignored except this README. They are deliberate host-specific
exceptions to the portable configuration; keep credentials in their existing
keychain/environment storage, outside this repository.

- `zshrc.local`: linked to `~/.zshrc.local`, loaded after portable shell settings.
- `codex.toml`: merged over portable `.codex/config.toml` when deploying.

The active Codex configuration is generated, not symlinked: desktop-managed
paths, integrations and project trust stay in `codex.toml`. After changing
settings through the app, reconcile them into the portable or local source
before running installation again. `--check` detects configuration drift.
