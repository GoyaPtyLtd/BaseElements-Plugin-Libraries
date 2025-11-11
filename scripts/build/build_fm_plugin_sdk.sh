#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="fm_plugin_sdk"
ARCHIVE_NAME="fm_plugin_sdk.zip"

print_header "Starting ${LIBRARY_NAME} Extraction"

# Check if unzip is available
if ! command -v unzip &> /dev/null; then
    print_error "ERROR: unzip is not installed. Please install it first:"
    echo "  Ubuntu: sudo apt install unzip"
    echo "  macOS: brew install unzip"
    exit 1
fi

# Ensure output directory exists
mkdir -p "${OUTPUT_DIR}"

# Extract source archive to output/platforms/${PLATFORM}/
interactive_prompt \
    "Ready to extract ${LIBRARY_NAME} archive" \
    "Archive: ${SOURCE_ARCHIVES}/${ARCHIVE_NAME}" \
    "Destination: ${OUTPUT_DIR}"

print_info "Extracting ${ARCHIVE_NAME} to ${OUTPUT_DIR}..."

cd "${OUTPUT_DIR}"
unzip -q "${SOURCE_ARCHIVES}/${ARCHIVE_NAME}"

print_success "Extraction complete for ${LIBRARY_NAME}"

