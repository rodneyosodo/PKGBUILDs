MAINTAINER_NAME := $(shell git config user.name 2>/dev/null)
MAINTAINER_EMAIL := $(shell git config user.email 2>/dev/null)
MAINTAINER := $(if $(MAINTAINER_NAME),$(MAINTAINER_NAME) <$(MAINTAINER_EMAIL)>,Your Name <youremail@domain.com>)

.PHONY: help create

help: ## Show this help
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-28s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

create: ## Create a new package (Usage: make create name=<package-name>)
	@if [ ! -f /etc/arch-release ]; then \
		echo "Error: Only supported on Arch Linux"; exit 1; fi
	@[ -n "$(name)" ] || (echo "Error: Usage: make create name=<pkgname>" && exit 1)
	@mkdir -p $(name); \
	sed -e "s|^# Maintainer:.*|# Maintainer: $(MAINTAINER)|" \
	    -e "s|pkgname=NAME|pkgname=$(name)|" \
	    -e "s|pkgver=VERSION|pkgver=1.0.0|" \
	    -e 's|pkgdesc=""|pkgdesc="$(name) description"|' \
	    /usr/share/pacman/PKGBUILD.proto > $(name)/PKGBUILD; \
	echo "Created $(name)/PKGBUILD"
