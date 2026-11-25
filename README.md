# [PKGBUILDs](https://wiki.archlinux.org/index.php/PKGBUILD)

This repository contains Arch Linux packages I maintain in the [AUR](https://aur.archlinux.org/packages?SeB=m&K=rodneyosodo)

Powered by [nvchecker](https://github.com/lilydjwg/nvchecker/) & [aurpublish](https://github.com/eli-schwartz/aurpublish).

## Packages

| Package                                                                         | Install                                                          |
| ------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| [ladybird-nightly-bin](https://aur.archlinux.org/packages/ladybird-nightly-bin) | `yay -S ladybird-nightly-bin` (prebuilt nightly, no local build) |
| [ladybird-nightly-git](https://aur.archlinux.org/packages/ladybird-nightly-git) | `yay -S ladybird-nightly-git` (builds from source)               |

## CI

Each package has a workflow in [.github/workflows](.github/workflows). It lints the PKGBUILD, checks `.SRCINFO` is up to date, and publishes to the AUR when the package changes on `main`. Ladybird is also built nightly: the package is attached to a [GitHub Release](../../releases) and `ladybird-nightly-bin` is updated to install it. Publishing needs the `AUR_SSH_PRIVATE_KEY` repository secret: the private half of an SSH key added to your AUR account.
