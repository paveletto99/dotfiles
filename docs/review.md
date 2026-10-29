# Manual review

Sections marked `REVIEW:` are preserved decisions requiring human judgment.
The active configuration is based on the live Mac. Conflicting incoming choices
are commented under `REVIEW: Incoming` in their canonical configuration file.

| Area | Preserved behavior / outstanding choice |
| --- | --- |
| Git identity | Live `user.email` ends in `gmail.commit`; historical config uses `gmail.com`. Confirm the intended identity before making commits. |
| Git pulls | `pull.rebase=true` and `pull.ff=only` are both retained. Choose a different pull policy only deliberately. |
| Git shortcuts | Existing force-push/master aliases remain unchanged. The missing `git-branch-status` helper's alias is commented out. |
| Podman | Ignored `local/zshrc.local` preserves the rootless localhost endpoint. Podman's current default connection is rootful. Reconcile the intended Docker-compatible endpoint manually; machine connections and identity files are not published. |
| Starship | Retained `command_timeout=2000`; measure large-repository prompt latency before lowering it. |
| Home LAN | The `lips` alias still scans `192.168.1.0/24`. |
| Removed aliases | Native ls/find/ps/tree replace exa/fd/procs/broot aliases; top now uses installed btop. Existing exa remains installed but is not a managed dependency. The old sudo/docker cleanup alias is inactive. |
| Tap tools | Dagger, Packer, cross-compilers and musl-cross need explicit tap-trust decisions on fresh hosts. The active Brewfile entries identify their origins; no trust is granted automatically. |
| TFLint | Retain an existing core-installed binary. Fresh macOS installs use the upstream terraform-linters/tap cask; Linux uses the official Go module. Review tap trust before adopting the macOS cask. |
| Terraform | The existing core-installed 1.5.7 remains untouched. Select the future version/source manually; no OpenTofu substitution is made. |
| Other installed formulae | merve and nbytes lack a recorded installation reason. The full inventory distinguishes observed presence from intended usage. |
| Ioskeley font | Downloaded font metadata says `IoskeleyMono Nerd Font`; the current archive has no separate hinting directories. Config uses its actual family. The previous Departure Mono font remains installed. |
| Neovim | The moved checkout retains its dirty lazy-lock.json and untracked version file. Decide whether to commit these in vim-setup; they are not part of the parent repo's gitlink. |
| Codex permissions | Existing live permission/model preferences are retained, including their current permissive policies. Review before reusing on another host. Host integrations and project trust are ignored local inputs. |
| Generated hooks | Existing Herdr-generated Codex hooks remain managed by Herdr. They are not rewritten or versioned by dotfiles. Fresh hosts may need Herdr's integration setup. |
| Editors on Linux | Shared settings are deployed, but installing Ghostty/Zed/VS Code GUIs is manual on Linux. Native ARM64 compatibility remains unverified here. |
| Imported extras | Unique skills/themes are consolidated in their standard directories. Atuin, OpenCode, GitHub CLI and Zellij packages are included in Brewfile; their configs remain undeployed by default. Conflicting shell bindings, signing and appearance settings are commented in the canonical files. |
| OpenCode | Review inherited model limits, plugin versions, MCP endpoints and permissions before enabling it. Its `orng` TUI theme is not included in OpenCode's theme directory. Compare settings with the work PC before adopting them. |
| Historical Linux setup | Replaced Docker/source-build/download installers have been removed. Incoming Zellij, editor and SSH preferences now live at their canonical paths; conflicting preferences are commented. The active installer uses native Podman and managed packages. |
| Remaining imported task | Review the plannotator configuration from mullroy before adding it. |

The single installer and Brewfile are authoritative. Superseded configuration
copies and runtime state are removed from the working tree, with original content
retained in Git history. Incoming alternatives remain disabled until reviewed.
