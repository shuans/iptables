#!/bin/sh
set -eu

arch=${1:?usage: build-static.sh ARCH VERSION}
version=${2:?usage: build-static.sh ARCH VERSION}
case "$arch" in
  amd64|arm64) ;;
  *) echo "unsupported architecture: $arch" >&2; exit 1 ;;
esac

apk add --no-cache \
  autoconf automake binutils build-base file libtool linux-headers \
  libmnl-dev libmnl-static libnftnl-dev pkgconf

./autogen.sh
./configure \
  --prefix=/usr \
  --enable-static \
  --disable-shared \
  --disable-connlabel \
  --disable-libnfnetlink \
  CFLAGS='-Os' \
  LDFLAGS='-static'
make -j "$(nproc)"

out="dist/iptables-${version}-linux-${arch}"
mkdir -p "$out/bin"
install -m 0755 iptables/xtables-legacy-multi "$out/bin/xtables-legacy-multi"
install -m 0755 iptables/xtables-nft-multi "$out/bin/xtables-nft-multi"

for family in iptables ip6tables; do
  for suffix in '' -restore -save; do
    ln -s xtables-nft-multi "$out/bin/${family}${suffix}"
    ln -s xtables-nft-multi "$out/bin/${family}-nft${suffix}"
    ln -s xtables-legacy-multi "$out/bin/${family}-legacy${suffix}"
  done
done

for binary in "$out"/bin/xtables-*-multi; do
  file "$binary"
  if readelf -l "$binary" | grep -q INTERP; then
    echo "binary is dynamically linked: $binary" >&2
    exit 1
  fi
done

"$out/bin/iptables" --version
"$out/bin/ip6tables" --version
cp COPYING "$out/"
tar -C dist -czf "dist/iptables-${version}-linux-${arch}.tar.gz" "iptables-${version}-linux-${arch}"
sha256sum "dist/iptables-${version}-linux-${arch}.tar.gz" > "dist/iptables-${version}-linux-${arch}.tar.gz.sha256"
