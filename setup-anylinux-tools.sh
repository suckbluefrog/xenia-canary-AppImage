#!/bin/sh

set -eu

QUICK_SHARUN=${QUICK_SHARUN:-https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh}
DEBLOATED_PACKAGES=${DEBLOATED_PACKAGES:-https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh}
MAKE_AUR_PACKAGE=${MAKE_AUR_PACKAGE:-https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/make-aur-package.sh}
ANYLINUX_TOOLS_DIR=${ANYLINUX_TOOLS_DIR:-/usr/local/bin}

as_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	else
		sudo "$@"
	fi
}

download_tool() {
	echo "Downloading '$2' to '$1'"
	if command -v wget >/dev/null 2>&1; then
		wget --retry-connrefused --tries=30 -O "$1" "$2"
	else
		curl -L --retry 30 --retry-connrefused -o "$1" "$2"
	fi
}

echo "Installing basic packaging dependencies..."
echo "---------------------------------------------------------------"

if command -v apt-get >/dev/null 2>&1; then
	as_root apt-get update
	as_root env DEBIAN_FRONTEND=noninteractive apt-get -y install \
		7zip \
		build-essential \
		ca-certificates \
		curl \
		file \
		git \
		jq \
		libfreetype6 \
		libnss-mdns \
		libnss-myhostname \
		libnss3 \
		libpulse0 \
		libx11-6 \
		libxrandr2 \
		libxss1 \
		patchelf \
		pulseaudio \
		squashfs-tools \
		unzip \
		wget \
		xvfb \
		zsync
elif command -v pacman >/dev/null 2>&1; then
	pacman-key --init
	pacman -Syy --noconfirm archlinux-keyring
	pacman -Syu --noconfirm \
		7zip \
		base-devel \
		freetype2 \
		git \
		jq \
		libx11 \
		libxrandr \
		libxss \
		nspr \
		nss \
		nss-mdns \
		nss-myhostname \
		patchelf \
		pulseaudio \
		pulseaudio-alsa \
		unzip \
		wget \
		xorg-server-xvfb \
		zsync
else
	echo "Unsupported package manager. Need apt-get or pacman." >&2
	exit 1
fi

as_root mkdir -p "$ANYLINUX_TOOLS_DIR"

download_tool /tmp/quick-sharun "$QUICK_SHARUN"
download_tool /tmp/get-debloated-pkgs "$DEBLOATED_PACKAGES"
download_tool /tmp/make-aur-package "$MAKE_AUR_PACKAGE"

as_root install -m 755 /tmp/quick-sharun "$ANYLINUX_TOOLS_DIR/quick-sharun"
as_root install -m 755 /tmp/get-debloated-pkgs "$ANYLINUX_TOOLS_DIR/get-debloated-pkgs"
as_root install -m 755 /tmp/make-aur-package "$ANYLINUX_TOOLS_DIR/make-aur-package"

echo "Packaging tools installed in $ANYLINUX_TOOLS_DIR."
