#!/bin/bash
# Shared platform detection and path setup for build scripts
# Source this file in build scripts to get platform detection and paths
# Usage: source "$(dirname "$0")/build-setup.sh"

# Get script directory and determine project paths
# This works whether sourced from scripts/build/ or scripts/2_build.sh
if [[ -n "${BASH_SOURCE[0]}" ]]; then
    # Sourced from a script
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # Called directly (fallback)
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_BASE="${PROJECT_ROOT}/source"
OUTPUT_BASE="${PROJECT_ROOT}/output"

# Detect platform (OS and architecture)
# Uses new packages system naming: ubuntu20_04-x86_64, macos-arm64_x86_64, etc.
OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1
PLATFORM='unknown'

if [[ $OS = 'Darwin' ]]; then
	# Use lowercase 'macos' to match GitHub Actions and packages system
	PLATFORM='macos-arm64_x86_64'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
elif [[ $OS = 'Linux' ]]; then
    JOBS=$(($(nproc) + 1))
    # Detect Ubuntu version from /etc/os-release
    if [[ ! -r /etc/os-release ]]; then
        echo "ERROR: Cannot read /etc/os-release" >&2
        return 1 2>/dev/null || exit 1
    fi
    
    os_id="$(. /etc/os-release && echo "$ID")"
    version_id="$(. /etc/os-release && echo "$VERSION_ID")"
    
    if [[ "$os_id" != "ubuntu" ]]; then
        echo "ERROR: This script requires Ubuntu. Detected: $os_id" >&2
        return 1 2>/dev/null || exit 1
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
            echo "ERROR: Unsupported Ubuntu version: ${version_id}" >&2
            echo "       Supported versions: 20.04, 22.04, 24.04" >&2
            return 1 2>/dev/null || exit 1
            ;;
    esac
    
    # Map architecture to platform name
    if [[ $ARCH != 'aarch64' ]] && [[ $ARCH != 'x86_64' ]]; then
        echo "ERROR: Unsupported architecture: $ARCH" >&2
        return 1 2>/dev/null || exit 1
    fi
    PLATFORM="${ubuntu_version}-${ARCH}"
fi

if [[ "${PLATFORM}" = 'unknown' ]]; then
	echo "ERROR: Unknown OS/ARCH: $OS/$ARCH" >&2
	return 1 2>/dev/null || exit 1
fi

# Export variables so they're available to sourced scripts and subprocesses
export OS
export ARCH
export JOBS
export PLATFORM
export PROJECT_ROOT
export SOURCE_BASE
export OUTPUT_BASE

# Set up output paths (new packages system)
OUTPUT_DIR="${OUTPUT_BASE}/platforms/${PLATFORM}"
OUTPUT_INCLUDE="${OUTPUT_DIR}/include"
OUTPUT_LIB="${OUTPUT_DIR}/lib"
OUTPUT_SRC="${OUTPUT_DIR}/src"

# Source archives are in source/ directory
# Extracted source should go to OUTPUT_SRC for new system
SOURCE_ARCHIVES="${SOURCE_BASE}"

export OUTPUT_DIR
export OUTPUT_INCLUDE
export OUTPUT_LIB
export OUTPUT_SRC
export SOURCE_ARCHIVES


