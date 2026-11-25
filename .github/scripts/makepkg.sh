#!/usr/bin/env bash
# Runs makepkg for one package inside an Arch Linux container, as an unprivileged user (makepkg refuses root).
#
#   makepkg.sh check <pkgdir>   lint the PKGBUILD and fail if .SRCINFO is out of date
#   makepkg.sh build <pkgdir>   install the dependencies and build the package
set -euo pipefail

mode=$1
pkgdir=$2

pacman -Syu --noconfirm --needed base-devel git namcap

useradd --create-home builder 2>/dev/null || true
echo 'builder ALL=(ALL) NOPASSWD: /usr/bin/pacman' >/etc/sudoers.d/builder
work=/home/builder/pkg
rm -rf "$work"
cp -r "$pkgdir" "$work"
chown -R builder:builder "$work"

as_builder() { runuser -u builder -- bash -c "cd '$work' && $1"; }

case "$mode" in
check)
  namcap "$work/PKGBUILD"
  as_builder 'makepkg --printsrcinfo' >/tmp/.SRCINFO
  if ! diff -u "$pkgdir/.SRCINFO" /tmp/.SRCINFO; then
    echo "::error file=$pkgdir/.SRCINFO::.SRCINFO is out of date. Run: makepkg --printsrcinfo > .SRCINFO"
    exit 1
  fi
  ;;
build)
  as_builder 'makepkg --syncdeps --noconfirm --noprogressbar'
  namcap "$work"/*.pkg.tar.zst
  mkdir -p "$pkgdir/out"
  cp "$work"/*.pkg.tar.zst "$pkgdir/out/"
  ;;
*)
  echo "unknown mode: $mode" >&2
  exit 2
  ;;
esac
