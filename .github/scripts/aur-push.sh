#!/usr/bin/env bash
# Pushes a package's PKGBUILD and .SRCINFO to its AUR repository, creating the package on the first push.
# Needs AUR_SSH_PRIVATE_KEY in the environment.
#
#   aur-push.sh <pkgdir> <commit message>
set -euo pipefail

pkgdir=$1
message=$2
pkgname=$(sed -n 's/^pkgname = //p' "$pkgdir/.SRCINFO")

# Pass ssh explicit paths: in a job container $HOME is not the home directory that ssh reads ~/.ssh from.
sshdir=$(mktemp -d)
trap 'rm -rf "$sshdir"' EXIT
printf '%s\n' "$AUR_SSH_PRIVATE_KEY" >"$sshdir/key"
chmod 600 "$sshdir/key"
# The AUR's published ed25519 host key (SHA256:RFzBCUItH9LZS0cKB5UE6ceAYhBD5C8GeOBip8Z11+4).
echo 'aur.archlinux.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuBKrPzbawxA/k2g6NcyV5jmqwJ2s+zpgZGZ7tpLIcN' \
  >"$sshdir/known_hosts"
export GIT_SSH_COMMAND="ssh -F /dev/null -i $sshdir/key -o IdentitiesOnly=yes -o UserKnownHostsFile=$sshdir/known_hosts -o StrictHostKeyChecking=yes"

aur=$(mktemp -d)
git clone "ssh://aur@aur.archlinux.org/$pkgname.git" "$aur"
# Mirror the package exactly, so files that are no longer part of it (or that an earlier maintainer of a reused
# package name left behind) are removed from the AUR.
git -C "$aur" rm -rq --ignore-unmatch .
find "$pkgdir" -maxdepth 1 -type f ! -name '*.pkg.tar.*' -exec cp -t "$aur/" {} +
cd "$aur"
git config user.name "${GIT_AUTHOR_NAME:-github-actions}"
git config user.email "${GIT_AUTHOR_EMAIL:-github-actions@users.noreply.github.com}"
git add -A
if git diff --cached --quiet; then
  echo "$pkgname is already up to date on the AUR."
  exit 0
fi
git commit -m "$message"
git push origin HEAD:master
