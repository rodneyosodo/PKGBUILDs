# [PKGBUILDs](https://wiki.archlinux.org/index.php/PKGBUILD)

This repository contains Arch Linux packages I maintain in the [AUR](https://aur.archlinux.org/packages?SeB=m&K=rodneyosodo)

Powered by [nvchecker](https://github.com/lilydjwg/nvchecker/) & [aurpublish](https://github.com/eli-schwartz/aurpublish).

## Packages

| Package                                                                         | Install                                                          |
| ------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| [ladybird-nightly-bin](https://aur.archlinux.org/packages/ladybird-nightly-bin) | `yay -S ladybird-nightly-bin` (prebuilt nightly, no local build) |
| [ladybird-nightly-git](https://aur.archlinux.org/packages/ladybird-nightly-git) | `yay -S ladybird-nightly-git` (builds from source)               |
| [yogurt-appimage](https://aur.archlinux.org/packages/yogurt-appimage)           | `yay -S yogurt-appimage` (official AppImage, updated on release) |
| [dusk](https://aur.archlinux.org/packages/dusk)                                 | `yay -S dusk` (builds from source)                               |
| [dusk-bin](https://aur.archlinux.org/packages/dusk-bin)                         | `yay -S dusk-bin` (prebuilt release binary)                      |
| [clacks](https://aur.archlinux.org/packages/clacks)                             | `yay -S clacks` (builds from source)                             |
| [clacks-bin](https://aur.archlinux.org/packages/clacks-bin)                     | `yay -S clacks-bin` (prebuilt release binary)                    |

## CI

Workflows in [.github/workflows](.github/workflows) lint each PKGBUILD, check `.SRCINFO` is up to date, and publish
to the AUR when a package changes on `main`.

- [ladybird.yml](.github/workflows/ladybird.yml): `ladybird-nightly-git` is published as is. Ladybird is also built
  nightly, attached to a [GitHub Release](../../releases), and `ladybird-nightly-bin` is updated to install it.
- [release-packages.yml](.github/workflows/release-packages.yml): every three hours, packages that follow an
  upstream GitHub release (`yogurt-appimage`, `dusk`, `dusk-bin`, `clacks`, `clacks-bin`) are checked for a new
  release. A new one updates `pkgver` and the checksums, is committed to `main` and is published.

Publishing needs the `AUR_SSH_PRIVATE_KEY` repository secret: the private half of an SSH key added to your AUR
account.
