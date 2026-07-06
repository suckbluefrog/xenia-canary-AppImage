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

remove_bundled_vulkan_drivers() {
	for lib_dir in ./AppDir/lib ./AppDir/lib64 ./AppDir/usr/lib ./AppDir/usr/lib64; do
		[ -d "$lib_dir" ] || continue
		find "$lib_dir" -maxdepth 1 -type f \( \
			-name 'libvulkan_*.so*' -o \
			-name 'libVkLayer_*.so*' \
		\) -print -delete
	done

	for data_dir in ./AppDir/share/vulkan ./AppDir/usr/share/vulkan ./AppDir/etc/vulkan ./AppDir/usr/etc/vulkan; do
		[ -d "$data_dir" ] || continue
		rm -rf \
			"$data_dir/icd.d" \
			"$data_dir/implicit_layer.d" \
			"$data_dir/explicit_layer.d"
	done
}

remove_bundled_glibc_core() {
	for lib_dir in ./AppDir/lib ./AppDir/lib64 ./AppDir/usr/lib ./AppDir/usr/lib64; do
		[ -d "$lib_dir" ] || continue
		find "$lib_dir" -maxdepth 1 \( -type f -o -type l \) \( \
			-name 'libanl.so*' -o \
			-name 'libBrokenLocale.so*' -o \
			-name 'libc.so*' -o \
			-name 'libcrypt.so*' -o \
			-name 'libdl.so*' -o \
			-name 'libm.so*' -o \
			-name 'libnsl.so*' -o \
			-name 'libpthread.so*' -o \
			-name 'libresolv.so*' -o \
			-name 'librt.so*' -o \
			-name 'libthread_db.so*' -o \
			-name 'libutil.so*' \
		\) -print -delete
	done
}

add_host_vulkan_hook() {
	mkdir -p ./AppDir/bin
	cat > ./AppDir/bin/00-host-vulkan-drivers.hook <<'EOF'
# Prefer host Vulkan ICDs. GPU driver libraries must match the host kernel,
# firmware, DRM stack, and board setup, especially with external PCIe GPUs.
if [ -z "${VK_DRIVER_FILES:-}" ] && [ -z "${VK_ICD_FILENAMES:-}" ]; then
	host_vulkan_icds=""
	for host_vulkan_icd_dir in \
		/etc/vulkan/icd.d \
		/usr/local/share/vulkan/icd.d \
		/usr/share/vulkan/icd.d \
		/usr/lib64/vulkan/icd.d \
		/usr/lib/vulkan/icd.d
	do
		[ -d "$host_vulkan_icd_dir" ] || continue
		for host_vulkan_icd in "$host_vulkan_icd_dir"/*.json; do
			[ -f "$host_vulkan_icd" ] || continue
			host_vulkan_icds="${host_vulkan_icds:+$host_vulkan_icds:}$host_vulkan_icd"
		done
	done

	if [ -n "$host_vulkan_icds" ]; then
		export VK_DRIVER_FILES="$host_vulkan_icds"
		export VK_ICD_FILENAMES="$host_vulkan_icds"
	fi
fi
EOF
}

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

remove_bundled_vulkan_drivers
remove_bundled_glibc_core
add_host_vulkan_hook

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
# quick-sharun --test ./dist/*.AppImage

# test is disable because the application is not able to run in docker at all!
