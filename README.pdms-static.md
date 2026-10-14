# Static iptables for pdms

GitHub Actions builds musl-linked `iptables` binaries for Linux amd64 and arm64.
Each release includes `iptables-<version>-linux-<arch>.tar.gz`, a source archive,
and `SHA256SUMS`.

The archive contains both `xtables-nft-multi` and `xtables-legacy-multi` with
their command symlinks. The plain `iptables` and `ip6tables` names select the
nft backend. All shipped xtables extensions are built into the binaries.

To publish a release, push a tag such as `pdms-v1.8.13.1`. The `pdms-v`
prefix keeps distribution tags separate from upstream iptables tags. CI builds
both architectures, checks for ELF dynamic interpreters, runs version commands,
and publishes archives only if both jobs succeed.

These userspace binaries still require corresponding kernel netfilter support
and permission to configure rules inside the selected network namespace.
