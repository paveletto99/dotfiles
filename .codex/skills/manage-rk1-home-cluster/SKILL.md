---
name: manage-rk1-home-cluster
description: Safely inspect, change, validate, and operate the RK1 ARM64 home cluster Ansible repository. Use when working on its inventory, host variables, pinned binary artifacts, filesystem overlay, rk1-bootstrap, systemd units, SPIFFE/SPIRE identity registrations, Envoy SDS/mTLS, NATS, Temporal, or observability configuration.
---

# RK1 Home Cluster Operations

Operate this repository as immutable, host-based infrastructure. Deploy through Ansible; let `rk1-bootstrap.service` converge node-local users, rendered configuration, storage, and enabled services.

## Establish context

1. Locate the repository root from `ansible.cfg`, `inventory/hosts.yml`, and `playbooks/site.yml`.
2. Read `README.md`, the affected overlay files under `files/`, and the relevant portions of `playbooks/site.yml` before editing.
3. Inspect `git status --short` first and preserve unrelated local work.
4. Identify the target node(s), role, listener ports, identity, and storage impact before making a change. Read [references/cluster-reference.md](references/cluster-reference.md) for the authoritative topology and deployment flow.

## Preserve non-negotiable invariants

- Keep workloads as host systemd services; do not introduce Kubernetes or application-managed TLS.
- Bind applications to localhost. Expose inter-node NATS and Temporal only through their Envoy mTLS listeners.
- Obtain workload certificates through SPIRE Workload API SDS at `/run/spire/sockets/agent.sock`; never add static certificates or commit tokens/secrets.
- Create a least-privilege Unix user per workload/Envoy instance. Give only Envoy identities membership in `spire` so they can use the Workload API socket.
- Register SPIFFE identities before enabling an Envoy listener that depends on them. Keep `spiffe://home` and selector/Unix-user mappings consistent.
- Make changes idempotent. Put persistent convergence in the overlay and bootstrap, not in one-off host commands.
- Retain ARM64 artifact URLs, version pinning, and checksums. Do not invent a checksum; obtain it from a verified release artifact before adding one.

## Make changes in the right layer

- Change a packaged configuration, unit, Envoy config, or bootstrap script under `files/`; Ansible copies this overlay to `/`.
- Change wiring values such as addresses and ports in `group_vars/all.yml` and `templates/cluster.env.j2`; bootstrap renders SPIRE-agent and egress Envoy configs from `/etc/rk1/cluster.env`.
- Change node targeting in `inventory/hosts.yml`, and preserve the hostname-to-role contract implemented in `files/usr/local/sbin/rk1-bootstrap`.
- Change a binary in `group_vars/all.yml` and preserve its ARM64 URL, archive type, destination, aliases, and optional verified checksum.
- Change workload registrations in the idempotent registration tasks in `playbooks/site.yml`, delegating SPIRE writes to the `spire_server` host.

## Extend a service safely

Read [references/change-recipes.md](references/change-recipes.md) before adding a service, listener, identity, or storage path. Apply its full sequence: Unix principals, local application listener, Envoy configuration, SPIRE registration, bootstrap role enablement, and validation. Do not omit egress identity/RBAC alignment when a service calls NATS or Temporal.

## Validate and deploy

1. Review the rendered relationships: instance name maps to `envoy-<instance>` and `/etc/envoy/<instance>.yaml`; identity selector maps to the same Envoy Unix user; app target remains `127.0.0.1`.
2. Run `ansible-playbook --syntax-check playbooks/site.yml` from the repository root after Ansible changes. Use a non-mutating YAML/config parser only if already available; do not install tooling just for validation.
3. Review `git diff --check` and the relevant diff. Check that no join token, credential, or generated `agent.conf` has entered version control.
4. Only run `./scripts/run.sh` (or `./scripts/run.sh --limit <host>`) when deployment is requested and the target scope is explicit. Warn that the normal play generates SPIRE join tokens and restarts bootstrap.
5. After a deployment, verify `rk1-bootstrap.service`, role services, `/run/spire/sockets/agent.sock`, required listeners, and Envoy local admin stats. Use the commands in [references/cluster-reference.md](references/cluster-reference.md).

## Diagnose without creating drift

Inspect unit state, bootstrap logs, socket permissions, listener bindings, Envoy admin stats, and SPIRE registrations. Trace failures in this order: agent health and socket access; correct selector/identity; Envoy SDS; Envoy RBAC; upstream localhost application. Propose repository/overlay fixes and reapply Ansible instead of repairing a node manually.
