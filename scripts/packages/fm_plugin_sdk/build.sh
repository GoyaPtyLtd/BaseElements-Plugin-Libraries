#!/usr/bin/env bash

# --- BOILERPLATE ---
# Determine this script's directory.
REALDIR=$(dirname "$(realpath "$0")")
cd "${REALDIR}" || exit 1
# --- BOILERPLATE ---

# Build package.
#
# Almost every package will need to define a build() function.
#
# Only a virtual package does not define a build() function. It is just used
# as a way to group DEPENDENCIES in the "package" file.
#
# Uses global variables:
#   PACKAGE_SRC      - from fetch()
#   PLATFORM
#   PLATFORM_INCLUDE
#   PLATFORM_LIBS
#   PLATFORM_FRAMEWORKS
#   BUILD_LOG
build() {
    print_ok "Installing."
    if [[ "${PLATFORM}" =~ ^macos ]]; then

        rsync -qr "${PACKAGE_SRC}/PlugInSDK/Libraries/Mac/FMWrapper.framework" "${PLATFORM_FRAMEWORKS}"

    elif [[ "${PLATFORM}" =~ ^ubuntu ]]; then

        # Extract ubuntu version and arch from PLATFORM: e.g. ubuntu22_04-aarch64
        local plat_os plat_arch
        plat_os="${PLATFORM%%-*}"               # ubuntu22_04
        plat_arch="${PLATFORM##*-}"             # aarch64
        local plat_os_version plat_os_major
        plat_os_version="${plat_os#ubuntu}"     # 22_04
        plat_os_major="${plat_os_version%%_*}"  # 22

        local fm_sdk_arch
        case "${plat_arch}" in
            "x86_64")
                fm_sdk_arch="x64"
                ;;
            "aarch64")
                fm_sdk_arch="arm64"
                ;;
            *)
                echo "Unknown architecture: ${plat_arch}"
                exit 1
                ;;
        esac

        local fm_sdk_so_lib_path="U${plat_os_major}/${fm_sdk_arch}"  # U22/arm64

        rsync -qr "${PACKAGE_SRC}/PlugInSDK/Libraries/Linux/${fm_sdk_so_lib_path}/libFMWrapper.so" "${PLATFORM_LIBS}"
        rsync -qr "${PACKAGE_SRC}/PlugInSDK/Headers/FMWrapper" "${PLATFORM_INCLUDE}"
    fi
}

# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
