#!/usr/bin/env bash
# Pushes a package's PKGBUILD and .SRCINFO to its AUR repository, creating the package on the first push.
# Needs AUR_SSH_PRIVATE_KEY in the environment.
#
#   aur-push.sh <pkgdir> <commit message>
set -euo pipefail

pkgdir=$1
message=$2
pkgname=$(sed -n 's/^pkgname = //p' "$pkgdir/.SRCINFO")

install -dm700 ~/.ssh
printf '%s\n' "$AUR_SSH_PRIVATE_KEY" >~/.ssh/aur
chmod 600 ~/.ssh/aur
ssh-keyscan -t ed25519 aur.archlinux.org >>~/.ssh/known_hosts 2>/dev/null
printf 'Host aur.archlinux.org\n  User aur\n  IdentityFile ~/.ssh/aur\n  IdentitiesOnly yes\n' >~/.ssh/config

aur=$(mktemp -d)
git clone "ssh://aur@aur.archlinux.org/$pkgname.git" "$aur"
cp "$pkgdir/PKGBUILD" "$pkgdir/.SRCINFO" "$aur/"
cd "$aur"
git config user.name "${GIT_AUTHOR_NAME:-github-actions}"
git config user.email "${GIT_AUTHOR_EMAIL:-github-actions@users.noreply.github.com}"
git add PKGBUILD .SRCINFO
if git diff --cached --quiet; then
  echo "$pkgname is already up to date on the AUR."
  exit 0
fi
git commit -m "$message"
git push origin HEAD:master
