# Cluster Reference

## Topology

| Host | Address | Role |
| --- | --- | --- |
| `rk1-node1` | `192.168.1.11` | SPIRE Server and Agent |
| `rk1-node2` | `192.168.1.12` | NATS/JetStream and Envoy |
| `rk1-node3` | `192.168.1.13` | Prometheus HA, Loki, Grafana, OpenTelemetry |
| `rk1-node4` | `192.168.1.14` | Temporal and Envoy |

Every node runs SPIRE Agent, node-exporter, fluent-bit, and NATS/Temporal egress Envoys. `rk1-bootstrap` selects the additional role services by the short hostname, so preserve these names and the inventory groups.

## Traffic and identity map

| Service | App binding | Envoy mTLS binding | Client local port | Server identity | Allowed client identity |
| --- | --- | --- | --- | --- | --- |
| NATS | `127.0.0.1:4222` on node2 | `0.0.0.0:4223` | `127.0.0.1:14223` | `spiffe://home/ns/core/sa/nats` | `^spiffe://home/ns/core/sa/.*$` |
| Temporal | `127.0.0.1:7233` on node4 | `0.0.0.0:7234` | `127.0.0.1:17234` | `spiffe://home/ns/workflows/sa/temporal` | `^spiffe://home/ns/workflows/sa/.*$` |

Client identity selectors are `unix:user:envoy-nats-egress` and `unix:user:envoy-temporal-egress`, with identities `.../nats-client` and `.../temporal-client`. Inbound selectors are `unix:user:envoy-nats` and `unix:user:envoy-temporal`. The Envoy instance template deliberately derives a distinct base ID from `%i`, allowing several Envoys per host.

SPIRE Agent identities follow `spiffe://home/agent/rk1-nodeX`. Envoy retrieves its leaf certificate and trust bundle from the local Workload API Unix socket. Bootstrap gives the `spire` group access to `/run/spire/sockets/agent.sock` after starting the agent.

## Configuration ownership

- `inventory/hosts.yml`: hosts and role groups.
- `group_vars/all.yml`: global IPs, trust domain, token behavior, ARM64 binary definitions and versions.
- `playbooks/site.yml`: overlay delivery, binary installation, join-token provisioning, and idempotent SPIRE registrations.
- `files/`: root filesystem overlay deployed by Ansible.
- `files/usr/local/sbin/rk1-bootstrap`: user/group setup, template rendering, storage preparation, and service enablement.
- `templates/cluster.env.j2`: generated shared network/trust configuration for bootstrap.

The regular playbook auto-generates one join token per `rk1` host by delegating to node1, writes each token as `/etc/spire/agent/join_token` mode `0600`, starts bootstrap, then creates SPIRE workload entries. Disable token automation only by explicitly supplying a real token using the documented variables; do not store it in the repository.

## Storage and observability

- Node3 mounts `/dev/sda1` at `/data` when present and prepares `/data/prometheus/a`, `/data/prometheus/b`, and `/data/loki`.
- Node4 mounts `/dev/nvme0n1p1` at `/nvme` when present and prepares `/nvme/temporal` and `/nvme/artifacts`; Temporal storage is owned by `svc-temporal`.
- Node3 starts `prometheus@a`, `prometheus@b`, `loki`, `grafana-server`, and `otelcol`.

## Operational checks

Run these on the relevant host after deployment:

```bash
systemctl is-active rk1-bootstrap.service
systemctl is-active spire-agent.service
ls -l /run/spire/sockets/agent.sock
ss -lntp
curl 127.0.0.1:9902/stats   # NATS inbound Envoy on node2
curl 127.0.0.1:9903/stats   # Temporal inbound Envoy on node4
spire-agent healthcheck
```

Use Envoy admin ports `9904` (NATS egress) and `9905` (Temporal egress) locally. Query `spire-server agent list` or `spire-server entry show` on node1 when investigating identity registration.
