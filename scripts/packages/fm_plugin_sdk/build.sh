#!/usr/bin/env bash

# --- BOILERPLATE ---
# Determine this script's directory.
REALDIR=$(dirname "$(realpath "$0")")
cd "${REALDIR}" || exit 1
# --- BOILERPLATE ---

# Unpack source package. Only called when ${PACKAGE_SOURCE_DIR} is missing/empty.
#
# Uses global variables:
#   PACKAGE_FILE            - from fetch()
#   PACKAGE_SOURCE_DIR   PACKAGE_SOURCE_DIR
unpack() {
    print_ok "Unpacking."
    mkdir -p "${PACKAGE_SOURCE_DIR}"
    unzip -q "${PACKAGE_FILE}" -d "${PACKAGE_SOURCE_DIR}"
}

# Build package.
#
# Almost every package will need to define a build() function.
#
# Only a virtual package does not define a build() function. It is just used
# as a way to group DEPENDENCIES in the "package" file.
#
# Uses global variables:
#   PACKAGE_SOURCE_DIR      - from fetch()
#   OS
#   PLATFORM
#   HEADERS_ROOT
#   LIBRARIES_PLATFORM_ROOT
#   FRAMEWORKS_ROOT
#   BUILD_LOG
build() {
    print_ok "Installing."
    if [[ "${PLATFORM}" == 'macOS' ]]; then

        rsync -qr "${PACKAGE_SOURCE_DIR}/PlugInSDK/Libraries/Mac/FMWrapper.framework" "${FRAMEWORKS_ROOT}"

    elif [[ "${OS}" == 'Linux' ]]; then

        local os_id="unknown"
        local version_id="unknown"
        local so_lib_path="/PlugInSDK/Libraries/Linux"

        if [[ -r /etc/os-release ]]; then
            os_id="$(. /etc/os-release && echo "$ID")"
            version_id="$(. /etc/os-release && echo "$VERSION_ID")"
        else
            print_error "No /etc/os-release, can't continue building."
            exit 1
        fi
        if [[ "$os_id" != "ubuntu" ]]; then
            print_error "Not ubuntu according to /etc/os-release, can't continue building."
            exit 1
        fi
        case "${version_id}" in
            "20.04")
                so_lib_path="${so_lib_path}/U20"
                ;;
            "22.04")
                so_lib_path="${so_lib_path}/U22"
                ;;
            *)
                print_error "Unsupported Ubuntu version: ${VERSION_ID}"
                exit 1
                ;;
        esac
        if [[ "${version_id}" != "20.04" ]]; then
            # Only Ubuntu 22.04 (and above) have a 64-bit ARM architecture.
            case "${ARCH}" in
                "x86_64")
                    so_lib_path="${so_lib_path}/x64"
                    ;;
                "aarch64")
                    so_lib_path="${so_lib_path}/arm64"
                    ;;
                *)
                    print_error "Unsupported architecture: ${ARCH}"
                    exit 1
                    ;;
            esac
        fi

        rsync -qr "${PACKAGE_SOURCE_DIR}/${so_lib_path}/libFMWrapper.so" "${LIBRARIES_PLATFORM_ROOT}"
        rsync -qr "${PACKAGE_SOURCE_DIR}/PlugInSDK/Headers/FMWrapper" "${HEADERS_ROOT}"
    fi
}

# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
