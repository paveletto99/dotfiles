# Manual review

Sections marked `REVIEW:` are preserved decisions requiring human judgment.
The active configuration is based on the live Mac; inactive inherited choices
are retained for inspection under `reference/`.

| Area | Preserved behavior / outstanding choice |
| --- | --- |
| Git identity | Live `user.email` ends in `gmail.commit`; historical config uses `gmail.com`. Confirm the intended identity before making commits. |
| Git pulls | `pull.rebase=true` and `pull.ff=only` are both retained. Choose a different pull policy only deliberately. |
| Git shortcuts | Existing force-push/master aliases remain unchanged. The missing `git-branch-status` helper's alias is commented out. |
| Podman | Ignored `local/zshrc.local` preserves the rootless localhost endpoint. Podman's current default connection is rootful. Reconcile the intended Docker-compatible endpoint manually; machine connections and identity files are not published. |
| Starship | Retained `command_timeout=2000`; measure large-repository prompt latency before lowering it. |
| Home LAN | The `lips` alias still scans `192.168.1.0/24`. |
| Removed aliases | Native ls/find/ps/tree replace exa/fd/procs/broot aliases; top now uses installed btop. Existing exa remains installed but is not a managed dependency. The old sudo/docker cleanup alias is inactive. |
| Tap tools | Dagger, Packer, cross-compilers and musl-cross need explicit tap-trust decisions on fresh hosts. The commented Brewfile entries identify their origins; no trust is granted automatically. |
| Terraform | The existing core-installed 1.5.7 remains untouched. Select the future version/source manually; no OpenTofu substitution is made. |
| Other installed formulae | merve and nbytes lack a recorded installation reason. The full inventory distinguishes observed presence from intended usage. |
| Ioskeley font | Downloaded font metadata says `IoskeleyMono Nerd Font`; the current archive has no separate hinting directories. Config uses its actual family. The previous Departure Mono font remains installed. |
| Neovim | The moved checkout retains its dirty lazy-lock.json and untracked version file. Decide whether to commit these in vim-setup; they are not part of the parent repo's gitlink. |
| Codex permissions | Existing live permission/model preferences are retained, including their current permissive policies. Review before reusing on another host. Host integrations and project trust are ignored local inputs. |
| Generated hooks | Existing Herdr-generated Codex hooks remain managed by Herdr. They are not rewritten or versioned by dotfiles. Fresh hosts may need Herdr's integration setup. |
| Editors on Linux | Shared settings are deployed, but installing Ghostty/Zed/VS Code GUIs is manual on Linux. Native ARM64 compatibility remains unverified here. |
| Repo-only extras | Original Atuin, OpenCode, skills, themes, alternate shell bindings, signing configuration and storage-provisioning documentation remain inactive in reference/initial-dotfiles. |
| Historical Linux setup | Docker services, old ARM64 downloads, Zellij, VS Code work connections and old SSH preferences remain disabled references. The active installer uses native Podman and modern shared packages. |

The repository has no initial commit yet. This migration does not commit or push
either repository, and it preserves unrelated staged cluster work in home-lab.
