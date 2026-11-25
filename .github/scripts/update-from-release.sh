#!/usr/bin/env bash
# Updates a package to the latest GitHub release of its upstream: pkgver, pkgrel=1, checksums and .SRCINFO.
# Runs as root in an Arch Linux container with pacman-contrib and jq installed. Prints the new version when it updated
# the package, and nothing when the package is already current.
#
#   update-from-release.sh <pkgdir> <owner/repo>
set -euo pipefail

pkgdir=$1
repo=$2

auth=()
[ -n "${GH_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $GH_TOKEN")
latest=$(curl -fsS "${auth[@]}" "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)
latest=${latest#v}
# The tag ends up in the PKGBUILD and a commit message, so accept only a plain version.
if [[ ! $latest =~ ^[0-9]+(\.[0-9A-Za-z]+)+$ ]]; then
  echo "::error::Unexpected release tag in $repo: $latest" >&2
  exit 1
fi

current=$(sed -n 's/^pkgver=//p' "$pkgdir/PKGBUILD")
echo "$pkgdir: current $current, latest $latest" >&2
if [ "$(vercmp "$latest" "$current")" -le 0 ]; then
  exit 0
fi

sed -i -e "s/^pkgver=.*/pkgver=$latest/" -e 's/^pkgrel=.*/pkgrel=1/' "$pkgdir/PKGBUILD"

id builder >/dev/null 2>&1 || useradd --create-home builder
work=$(mktemp -d)
# Local sources such as a systemd unit have to be there too.
find "$pkgdir" -maxdepth 1 -type f -exec cp -t "$work/" {} +
chown -R builder "$work"
# updpkgsums downloads the sources for every architecture to checksum them.
runuser -u builder -- bash -c "cd '$work' && updpkgsums && makepkg --printsrcinfo >.SRCINFO"
cp "$work/PKGBUILD" "$work/.SRCINFO" "$pkgdir/"
rm -rf "$work"

echo "$latest"
