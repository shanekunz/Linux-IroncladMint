#!/bin/bash
# Ensure system Flatpaks have NVIDIA libraries for now and after the next reboot.

set -euo pipefail

if ! command -v flatpak > /dev/null 2>&1; then
    echo "[sync-flatpak-nvidia] Skipping: Flatpak is not installed."
    exit 0
fi

declare -A nvidia_drivers=()
active_gl_drivers="$(flatpak --gl-drivers)"
while IFS= read -r gl_driver; do
    if [[ "$gl_driver" =~ ^nvidia-[0-9]+(-[0-9]+){1,2}$ ]]; then
        nvidia_drivers["$gl_driver"]=1
    fi
done <<< "$active_gl_drivers"

# APT can install a newer driver while the old kernel module is still loaded.
# Include the native NVIDIA GL package version to prepare for the next boot.
if command -v dpkg-query > /dev/null 2>&1 && command -v dpkg > /dev/null 2>&1; then
    native_arch="$(dpkg --print-architecture)"
    nvidia_packages="$(dpkg-query -W -f='${db:Status-Status}\t${Architecture}\t${Version}\n' 'libnvidia-gl-*' 2>/dev/null || true)"
    while IFS=$'\t' read -r package_status package_arch package_version; do
        [[ "$package_status" == installed && "$package_arch" == "$native_arch" ]] || continue
        driver_version="${package_version#*:}"
        driver_version="${driver_version%%-*}"
        if [[ "$driver_version" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]]; then
            nvidia_drivers["nvidia-${driver_version//./-}"]=1
        fi
    done <<< "$nvidia_packages"
fi

if [[ ${#nvidia_drivers[@]} -eq 0 ]]; then
    echo "[sync-flatpak-nvidia] Skipping: No NVIDIA driver detected."
    exit 0
fi

for gl_driver in "${!nvidia_drivers[@]}"; do
    driver_ref="org.freedesktop.Platform.GL.${gl_driver}//1.4"
    if flatpak info --system "$driver_ref" > /dev/null 2>&1; then
        echo "[sync-flatpak-nvidia] Already installed: $gl_driver"
    else
        echo "[sync-flatpak-nvidia] Installing matching graphics driver: $gl_driver"
        if ! flatpak install --system -y flathub "$driver_ref"; then
            echo "[sync-flatpak-nvidia] Failed to install $driver_ref. Check Flathub/network access and rerun this script." >&2
            exit 1
        fi
    fi
done
