# Change Recipes

## Add a meshed host service

1. Choose a node role, a non-conflicting local application port, a public mTLS port, an egress port if clients need one, an SPIFFE ID, and the exact allowed client-ID regex.
2. Add the service configuration and systemd unit to `files/etc/`. Run the application as `svc-<service>` and bind it to `127.0.0.1`; use `Restart=always`, `NoNewPrivileges=true`, and the least privilege needed by the application.
3. Add an inbound Envoy config that listens on the mTLS port, proxies only to the local app port, requires downstream client certificates, uses SDS via the Workload API socket, and contains network RBAC for the selected identities.
4. Add an egress Envoy template when clients need to reach the service. Bind it only to `127.0.0.1`, use upstream mTLS with an SDS client identity and the trust bundle, and render remote address/port from `cluster.env` rather than hard-coding them.
5. Add `svc-<service>`, `envoy-<service>`, and any `envoy-<service>-egress` users/groups to `rk1-bootstrap`. Add only the Envoy users to group `spire`; create state and log directories with correct ownership.
6. Add role-specific `enable_and_start` calls in the hostname case, ensuring the app starts before its inbound Envoy. Start shared egress instances in the baseline section only when every node needs them.
7. Add idempotent SPIRE entry tasks in `playbooks/site.yml`, delegated to `spire_server`. Use the Envoy Unix-user selector that exactly matches bootstrap. Place the registration before bootstrap enables a newly dependent Envoy whenever the parent agent ID is available. Register both leaf identities when an inbound and egress Envoy are used.
8. Add artifact metadata to `group_vars/all.yml` if the binary is bundled: ARM64 release URL, archive type, binary name, destination, and a verified checksum when available.
9. Run syntax/diff checks and, on requested deployment, limit first to the role host if safe. Verify local app, Envoy listener, SDS socket access, and an authorized/unauthorized client path.

## Change SPIRE or Envoy configuration

- Treat the Workload API socket and `spire` group permissions as a coupled change. Preserve `0750` directories and socket group read/write access for Envoy.
- Update both the SPIRE entry and the SDS `tls_certificate_sds_secret_configs` name together. Keep the trust-bundle SDS name `spiffe://home` unless changing the trust domain globally.
- Tighten RBAC expressions narrowly. Do not replace principal-based authorization with IP allowlists.
- Preserve `require_client_certificate: true` for inter-node listeners and do not expose an application listener on the LAN.
- Authorize the certificate presented by the client egress Envoy. Give independently authorized workloads distinct egress users and SPIFFE IDs; a shared egress identity cannot support a workload-specific allow-list.

## Add durable state

- Put node4 service data in its own `/nvme/<service>` directory and make it owned by the dedicated service user.
- Create the directory only after verifying the expected `/nvme` mount is present. Make the application fail closed or depend on mount readiness so an unavailable disk cannot create an empty data directory on the root filesystem.
- Validate the mount source and persistence across a service restart before treating the deployment as complete.

## Change addresses, ports, or node assignment

- Update the inventory address and the corresponding global variable together.
- Keep `templates/cluster.env.j2`, its consuming bootstrap renderer, and the Envoy template placeholders aligned.
- Move a role only after adding its hostname/role behavior to bootstrap and reassessing data storage/mount requirements.
- Treat a change to the node1 SPIRE server address or trust domain as cluster-wide. Revalidate every agent and Envoy identity rather than applying to one host in isolation.

## Upgrade a binary

1. Change the version and release URL together in `group_vars/all.yml`.
2. Verify the artifact is Linux ARM64 and its archive layout still supplies the configured `binary_name`.
3. Obtain and set a trusted checksum when available; leave an existing valid checksum in place unless the new artifact has a different verified digest.
4. Validate the installed binary's version after the requested deployment and inspect its systemd unit state.
