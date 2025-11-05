#!/bin/bash
# Cleans the output/platforms/${PLATFORM} directory, ready for fresh builds.
# Removes the entire platform directory and recreates it fresh.

set -e  # Exit immediately on any error - prevents script from continuing if operations fail

# Source common build functionality (platform detection, paths, colors, helpers)
source "$(dirname "$0")/build/_build_common.sh"

print_header "Cleaning output directory for ${PLATFORM}"

# Change to output directory
cd "${OUTPUT_BASE}" || {
    print_error "ERROR: Failed to change to output directory: ${OUTPUT_BASE}"
    exit 1
}

# Clean new structure (output/platforms/${PLATFORM}/)
# New packages system uses Ubuntu-specific platform names
# example: output/platforms/ubuntu20_04-x86_64/lib/
PLATFORM_DIR="./platforms/${PLATFORM}"

# Remove entire platform directory and recreate fresh structure
rm -rf "${PLATFORM_DIR}"
mkdir -p "${PLATFORM_DIR}/include"
mkdir -p "${PLATFORM_DIR}/lib"
mkdir -p "${PLATFORM_DIR}/src"
# Frameworks directory is used by macOS packages (e.g., fm_plugin_sdk)
if [[ $OS = 'Darwin' ]]; then
    mkdir -p "${PLATFORM_DIR}/frameworks"
fi

print_success "Cleanup complete for platform: ${PLATFORM}"
