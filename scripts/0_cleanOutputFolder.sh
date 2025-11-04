#!/bin/bash
# Cleans the Output/Platforms/${PLATFORM} directory, ready for fresh builds.
# Removes the entire platform directory and recreates it fresh.

set -e  # Exit immediately on any error - prevents script from continuing if operations fail

# Get script directory and determine paths based on script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../Output"

# Detect platform (OS and architecture)
# example 'ubuntu22_04-x86_64', 'ubuntu24_04-aarch64', etc.
OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1              # Number of parallel jobs
PLATFORM='unknown'

if [[ $OS = 'Darwin' ]]; then
	# Use lowercase 'macos' to match GitHub Actions and packages system
	# GitHub Actions uses: macos-14, macos-15, etc.
	# Packages system uses: macos-arm64_x86_64
	PLATFORM='macos-arm64_x86_64'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
elif [[ $OS = 'Linux' ]]; then
    JOBS=$(($(nproc) + 1))
    # Detect Ubuntu version from /etc/os-release
    os_id="unknown"
    version_id="unknown"
    ubuntu_version="unknown"
    
    if [[ -r /etc/os-release ]]; then
        os_id="$(. /etc/os-release && echo "$ID")"
        version_id="$(. /etc/os-release && echo "$VERSION_ID")"
    else
        echo "ERROR: Cannot read /etc/os-release"
        exit 1
    fi
    
    if [[ "$os_id" != "ubuntu" ]]; then
        echo "ERROR: This script requires Ubuntu. Detected: $os_id"
        exit 1
    fi
    
    # Map Ubuntu version to platform name
    case "${version_id}" in
        "20.04")
            ubuntu_version="ubuntu20_04"
            ;;
        "22.04")
            ubuntu_version="ubuntu22_04"
            ;;
        "24.04")
            ubuntu_version="ubuntu24_04"
            ;;

        *)
            echo "ERROR: Unsupported Ubuntu version: ${version_id}"
            echo "       Supported versions: 20.04, 22.04, 24.04"
            exit 1
            ;;
    esac
    
    # Map architecture to platform name
    if [[ $ARCH != 'aarch64' ]] && [[ $ARCH != 'x86_64' ]]; then
        echo "ERROR: Unsupported architecture: $ARCH"
        exit 1
    fi
    PLATFORM="${ubuntu_version}-${ARCH}"
fi

if [[ "${PLATFORM}" = 'unknown' ]]; then
	echo "ERROR: Unknown OS/ARCH: $OS/$ARCH"
	exit 1
fi

# Change to Output directory
cd "${OUTPUT_DIR}" || {
    echo "ERROR: Failed to change to Output directory: ${OUTPUT_DIR}"
    exit 1
}

# Clean new structure (Output/Platforms/${PLATFORM}/)
# New packages system uses Ubuntu-specific platform names
# example: Output/Platforms/ubuntu20_04-x86_64/lib/
PLATFORM_DIR="./Platforms/${PLATFORM}"

# Remove entire platform directory and recreate fresh
rm -rf "${PLATFORM_DIR}"

# Recreate platform directory structure
mkdir -p "${PLATFORM_DIR}/include"
mkdir -p "${PLATFORM_DIR}/lib"
mkdir -p "${PLATFORM_DIR}/src"
# Frameworks directory is used by macOS packages (e.g., fm_plugin_sdk)
if [[ $OS = 'Darwin' ]]; then
    mkdir -p "${PLATFORM_DIR}/frameworks"
fi

echo "Cleanup complete for platform: ${PLATFORM}"


