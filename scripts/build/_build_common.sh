#!/bin/bash
# Common build script functionality
# Provides platform detection, paths, interactive mode, colors, and helper functions
# Usage: source "$(dirname "$0")/_build_common.sh" "$@"

# ============================================================================
# PART 1: Interactive Mode and Color Setup
# ============================================================================

# Parse arguments for interactive mode
# Note: This consumes --interactive/-i from $@, leaving other args for the calling script
INTERACTIVE=0
ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --interactive|-i)
            INTERACTIVE=1
            shift
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done
# Restore remaining arguments for the calling script
set -- "${ARGS[@]}"

# Initialize colors using tput (more portable than ANSI codes)
# Falls back to ANSI codes if tput is not available
if [[ -t 1 ]]; then
    if command -v tput >/dev/null 2>&1; then
        COLOR_YELLOW=$(tput setaf 3 2>/dev/null || echo '\033[1;33m')
        COLOR_CYAN=$(tput setaf 6 2>/dev/null || echo '\033[0;36m')
        COLOR_GREEN=$(tput setaf 2 2>/dev/null || echo '\033[0;32m')
        COLOR_RED=$(tput setaf 1 2>/dev/null || echo '\033[0;31m')
        COLOR_RESET=$(tput sgr0 2>/dev/null || echo '\033[0m')
    else
        COLOR_YELLOW='\033[1;33m'
        COLOR_CYAN='\033[0;36m'
        COLOR_GREEN='\033[0;32m'
        COLOR_RED='\033[0;31m'
        COLOR_RESET='\033[0m'
    fi
else
    COLOR_YELLOW=''
    COLOR_CYAN=''
    COLOR_GREEN=''
    COLOR_RED=''
    COLOR_RESET=''
fi

# Export INTERACTIVE flag and colors for use in functions
export INTERACTIVE
export COLOR_YELLOW COLOR_CYAN COLOR_GREEN COLOR_RED COLOR_RESET

# ============================================================================
# PART 2: Platform Detection and Path Setup
# ============================================================================

# Get script directory and determine project paths
# This works whether sourced from scripts/build/*.sh or scripts/2_build.sh
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
# Uses new packages system naming: ubuntu20.04-x86_64, macos-arm64-x86_64, etc.
OS=$(uname -s)		# Linux|Darwin
# Detect architecture using uname -m
ARCH=$(uname -m)
# Normalize architecture names
case "${ARCH}" in
    "arm64")
        ARCH="aarch64"
        ;;
    "amd64")
        ARCH="x86_64"
        ;;
esac
JOBS=1
PLATFORM='unknown'

if [[ $OS = 'Darwin' ]]; then
	# Use lowercase 'macos' to match GitHub Actions and packages system
	PLATFORM='macos-arm64_x86_64'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
    # Set HOST triplet for configure scripts (follows packages system pattern)
    # Note: For universal builds, scripts should set HOST per-architecture
    # This sets a default based on the current architecture
    if [[ $ARCH = 'aarch64' ]] || [[ $ARCH = 'arm64' ]]; then
        HOST='arm64-apple-darwin'
    elif [[ $ARCH = 'x86_64' ]]; then
        HOST='x86_64-apple-darwin'
    fi
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
            ubuntu_version="ubuntu20.04"
            ;;
        "22.04")
            ubuntu_version="ubuntu22.04"
            ;;
        "24.04")
            ubuntu_version="ubuntu24.04"
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
# HOST is only set on macOS, so conditionally export it
if [[ -n "${HOST:-}" ]]; then
    export HOST
fi

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

# ============================================================================
# PART 3: Helper Functions
# ============================================================================

# Helper function: Print a section header
# Usage: print_header "Starting jq Build"
print_header() {
    local title="$1"
    echo -e "${COLOR_YELLOW}${title}${COLOR_RESET}"
}

# Helper function: Information message
# Usage: print_info "This is an information message"
print_info() {
    local message="$1"
    echo -e "${COLOR_CYAN}${message}${COLOR_RESET}"
}

# Helper function: Success message
# Usage: print_success "Build complete for jq"
print_success() {
    local message="$1"
    echo -e "${COLOR_GREEN}${message}${COLOR_RESET}"
}

# Helper function: Error message
# Usage: print_error "ERROR: Something went wrong"
print_error() {
    local message="$1"
    echo -e "${COLOR_RED}${message}${COLOR_RESET}" >&2
}

# Helper function: Interactive prompt with details
# Usage: interactive_prompt "Ready to build" "Platform: ${PLATFORM}" "Jobs: ${JOBS}"
interactive_prompt() {
    local title="$1"
    shift
    local details=("$@")
    
    if [[ $INTERACTIVE -eq 1 ]]; then
        echo ""
        echo -e "${COLOR_YELLOW}${title}${COLOR_RESET}"
        for detail in "${details[@]}"; do
            echo -e "${COLOR_CYAN}  ${detail}${COLOR_RESET}"
        done
        read -p "$(echo -e "${COLOR_YELLOW}Press Enter to continue, or Ctrl+C to cancel...${COLOR_RESET}") " dummy
    fi
}

# Export functions so they're available to calling scripts
export -f print_header
export -f print_info
export -f interactive_prompt
export -f print_success
export -f print_error

