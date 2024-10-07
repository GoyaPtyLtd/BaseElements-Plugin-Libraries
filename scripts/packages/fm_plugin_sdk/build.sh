#!/usr/bin/env bash

# --- BOILERPLATE ---
# Put us in this script's directory.
REALDIR=$(dirname "$(realpath "$0")")
cd "${REALDIR}" || exit 1
# --- BOILERPLATE ---

# Required functions:
#   build()
# Optional functions if builtin_* is insufficient:
#   fetch()
#   unpack()
#   build()
#   clean_source()
#   clean_output()
#   check_output()


# Fetch source package.
#
# Uses global variables:
#   NAME                    - package variable
#   SOURCE_URL              - package variable
#   SOURCE_HASH             - package variable
#   PACKAGE_DOWNLOAD_DIR
#   SOURCE_PLATFORM_ROOT
#
# Sets global variables:
#   PACKAGE_FILE            - Full path to downloaded package.
#   PACKAGE_SOURCE_DIR      - Full path to where source will be unpacked.
#
# Returns 0 (true) if the file was downloaded, 1 if it already exists.
#fetch() {
#}

# Unpack source package. Is only called when fetch() returns true.
#
# Uses global variables:
#   PACKAGE_FILE            - from fetch()
#   PACKAGE_SOURCE_DIR      - from fetch()
unpack() {
    mkdir -p "${PACKAGE_SOURCE_DIR}"
    unzip -q "${PACKAGE_FILE}" -d "${PACKAGE_SOURCE_DIR}"
}

# Build package.
#
# Uses global variables:
#   PACKAGE_SOURCE_DIR      - from fetch()
#   OS
#   PLATFORM
#   FRAMEWORKS_DIR
#   PACKAGE_LIBRARIES_DIR
#   HEADERS_ROOT
build() {
    if [[ "${PLATFORM}" == 'macOS' ]]; then

        rsync -qr "${PACKAGE_SOURCE_DIR}/PlugInSDK/Libraries/Mac/FMWrapper.framework" "${FRAMEWORKS_DIR}"

    elif [[ "${OS}" == 'Linux' ]]; then

        local os_id="unknown"
        local version_id="unknown"
        local so_lib_path="/PlugInSDK/Libraries/Linux"

        if [[ -r /etc/os-release ]]; then
            os_id="$(. /etc/os-release && echo "$ID")"
            version_id="$(. /etc/os-release && echo "$VERSION_ID")"
        else
            echo "!! No /etc/os-release, can't continue building."
            exit 1
        fi
        if [[ "$os_id" != "ubuntu" ]]; then
            echo "!! Not ubuntu according to /etc/os-release, can't continue building."
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
                echo "!! Unsupported Ubuntu version: ${VERSION_ID}"
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
                    echo "!! Unsupported architecture: ${ARCH}"
                    exit 1
                    ;;
            esac
        fi

        rsync -qr "${PACKAGE_SOURCE_DIR}/${so_lib_path}/libFMWrapper.so" "${PACKAGE_LIBRARIES_DIR}"
        rsync -qr "${PACKAGE_SOURCE_DIR}/PlugInSDK/Headers/FMWrapper" "${HEADERS_ROOT}"
    fi
}

# Clean source package.
#
# Uses global variables:
#   PACKAGE_SOURCE_DIR
#clean_source() {
#}

# Clean output files.
#
# Uses global variables:
#   LIBRARIES
#   FRAMEWORKS
#   HEADERS
#   LIBRARIES_DIR
#   FRAMEWORKS_DIR
#   HEADERS_DIR
#clean_output() {
#}

# Check output files / directories exist. Used to determine if the package
# has been installed.
#
# Uses global variables:
#   PLATFORM
#   LIBRARIES
#   FRAMEWORKS
#   HEADERS
#   LIBRARIES_DIR
#   FRAMEWORKS_DIR
#   HEADERS_DIR
#
# Returns 0 if all output exist, 1 if any are missing.
#check_output() {
#}

# --- BOILERPLATE ---
# Source this script after functions are defined.
source ../../build-functions
# --- BOILERPLATE ---
