#!/bin/sh

set -eu

ARCH="${ARCH:-$(uname -m)}"
case "$ARCH" in
	amd64) ARCH=x86_64 ;;
	arm64) ARCH=aarch64 ;;
esac
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
if [ -n "${GITHUB_REPOSITORY:-}" ]; then
	export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
fi
export ICON=https://raw.githubusercontent.com/xenia-canary/xenia-canary/refs/heads/canary_experimental/assets/icon/256.png
export DEPLOY_VULKAN=1

ALSA_PLUGINS=""
ALSA_PLUGIN_NAMES="
libasound_module_pcm_pipewire.so
libasound_module_ctl_pipewire.so
"
for plugin_dir in /usr/lib/alsa-lib /usr/lib64/alsa-lib; do
	[ -d "$plugin_dir" ] || continue
	for plugin_name in $ALSA_PLUGIN_NAMES; do
		plugin="$plugin_dir/$plugin_name"
		[ -f "$plugin" ] || continue
		ALSA_PLUGINS="$ALSA_PLUGINS $plugin"
	done
done

# ADD LIBRARIES
quick-sharun ./build/bin/Linux/Release/xenia_canary $ALSA_PLUGINS

# Additional changes can be done in between here
mkdir -p ./AppDir/lib/alsa-lib
for plugin in $ALSA_PLUGINS; do
	cp -a "$plugin" ./AppDir/lib/alsa-lib/
done

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
# quick-sharun --test ./dist/*.AppImage

# test is disable because the application is not able to run in docker at all!
