#!/bin/bash
# Bash 3 compatible - no bash 4+ features used

# Creates tarballs and SHA256 checksums for Ubuntu platform directories.
# Tarballs are created in output/platforms/ alongside the platform directories.

set -e

# Source common build functionality (colors, helpers)
source "$(dirname "$0")/build/_build_common.sh"

# Get script directory and determine project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_BASE="${PROJECT_ROOT}/output"
PLATFORMS_DIR="${OUTPUT_BASE}/platforms"

if [[ ! -d "$PLATFORMS_DIR" ]]; then
    print_error "ERROR: Platforms directory not found: ${PLATFORMS_DIR}"
    exit 1
fi

# Select tar command based on OS
# macOS: use gtar (GNU tar from Homebrew) for --transform support
# Ubuntu: use tar (GNU tar by default)
if [[ $OS = 'Darwin' ]]; then
    if command -v gtar >/dev/null 2>&1; then
        TAR_CMD="gtar"
        USE_TRANSFORM=true
    else
        print_error "ERROR: gtar (GNU tar) is required on macOS. Install with: brew install gnu-tar"
        exit 1
    fi
else
    # Linux/Ubuntu: use system tar (GNU tar)
    if command -v tar >/dev/null 2>&1; then
        TAR_CMD="tar"
        USE_TRANSFORM=true
    else
        print_error "ERROR: tar is not installed"
        exit 1
    fi
fi

# Check if sha256sum is available (Linux) or shasum (macOS)
if command -v sha256sum >/dev/null 2>&1; then
    SHA256_CMD="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
    SHA256_CMD="shasum -a 256"
else
    print_error "ERROR: Neither sha256sum nor shasum is available"
    exit 1
fi

print_header "Packaging platform directory"

# Use the current platform from _build_common.sh
# Support both Ubuntu and macOS platforms
case "$PLATFORM" in
    ubuntu*|macos*)
        # Valid platform
        ;;
    *)
        print_error "ERROR: This script only packages Ubuntu and macOS platforms. Current platform: ${PLATFORM}"
        exit 1
        ;;
esac

cd "$PLATFORMS_DIR" || {
    print_error "ERROR: Failed to change to platforms directory"
    exit 1
}

# Check if the current platform directory exists
if [[ ! -d "$PLATFORM" ]]; then
    print_error "ERROR: Platform directory not found: ${PLATFORM}"
    print_error "  Expected: ${PLATFORMS_DIR}/${PLATFORM}"
    exit 1
fi

print_info "Packaging platform: ${PLATFORM}"
echo ""

# Package the current platform
platform="$PLATFORM"
TARBALL_NAME="external-${platform}.tar.gz"
SHA256_NAME="external-${platform}.tar.gz.sha256"
PLATFORM_DIR="${PLATFORMS_DIR}/${platform}"
TEMP_PACKAGE_DIR="${PLATFORMS_DIR}/${platform}_package"

print_header "Packaging ${platform}"

# Remove old tarball and checksum if they exist
rm -f "$TARBALL_NAME" "$SHA256_NAME"
rm -rf "$TEMP_PACKAGE_DIR"

# Create temporary package directory with platform name (matching what copy script copies)
mkdir -p "$TEMP_PACKAGE_DIR"

# Copy include/ directory (headers) - copy contents like 3_copy.sh does
if [[ -d "${PLATFORM_DIR}/include" ]]; then
    print_info "  Including headers from include/"
    mkdir -p "${TEMP_PACKAGE_DIR}/include"
    cp -r "${PLATFORM_DIR}/include"/* "${TEMP_PACKAGE_DIR}/include/" 2>/dev/null || {
        print_error "ERROR: No headers found in ${PLATFORM_DIR}/include"
        exit 1
    }
fi

# Copy lib/ directory (libraries) - flatten structure like 3_copy.sh does
if [[ -d "${PLATFORM_DIR}/lib" ]]; then
    print_info "  Including libraries from lib/"
    mkdir -p "${TEMP_PACKAGE_DIR}/lib"
    # Copy all library files from all subdirectories (flatten structure)
    find "${PLATFORM_DIR}/lib" -name "*.a" -type f -exec cp {} "${TEMP_PACKAGE_DIR}/lib/" \; || {
        print_error "ERROR: No libraries found in ${PLATFORM_DIR}/lib"
        exit 1
    }
fi

# Copy duktape source files (if they exist)
if [[ -f "${PLATFORM_DIR}/src/duktape/src/duktape.c" ]] && \
   [[ -f "${PLATFORM_DIR}/src/duktape/src/duktape.h" ]] && \
   [[ -f "${PLATFORM_DIR}/src/duktape/src/duk_config.h" ]]; then
    print_info "  Including duktape source files"
    mkdir -p "${TEMP_PACKAGE_DIR}/src/duktape"
    cp "${PLATFORM_DIR}/src/duktape/src/duktape.c" "${TEMP_PACKAGE_DIR}/src/duktape/"
    cp "${PLATFORM_DIR}/src/duktape/src/duktape.h" "${TEMP_PACKAGE_DIR}/src/duktape/"
    cp "${PLATFORM_DIR}/src/duktape/src/duk_config.h" "${TEMP_PACKAGE_DIR}/src/duktape/"
fi

# Copy PlugInSDK (if it exists)
if [[ -d "${PLATFORM_DIR}/PlugInSDK" ]]; then
    print_info "  Including PlugInSDK"
    cp -R -P "${PLATFORM_DIR}/PlugInSDK" "$TEMP_PACKAGE_DIR/"
fi

# Copy FMWrapper headers to include directory (Nick requested this - macOS only)
if [[ $OS = 'Darwin' ]] && [[ -d "${PLATFORM_DIR}/PlugInSDK/Headers/FMWrapper" ]]; then
    print_info "  Including FMWrapper headers in include/"
    mkdir -p "${TEMP_PACKAGE_DIR}/include/FMWrapper"
    cp -r "${PLATFORM_DIR}/PlugInSDK/Headers/FMWrapper"/* "${TEMP_PACKAGE_DIR}/include/FMWrapper/"
fi

# Create tarball with platform name as top-level directory
print_info "Creating tarball: ${TARBALL_NAME}"
cd "$PLATFORMS_DIR"
$TAR_CMD -czf "$TARBALL_NAME" --transform "s|^${platform}_package|${platform}|" "${platform}_package"

# Clean up temporary directory
rm -rf "$TEMP_PACKAGE_DIR"

# Generate SHA256 checksum
print_info "Generating SHA256 checksum: ${SHA256_NAME}"
$SHA256_CMD "$TARBALL_NAME" > "$SHA256_NAME"

# Display the checksum
checksum=$(awk '{print $1}' "$SHA256_NAME")
print_success "Packaged ${platform}"
print_info "  Tarball: ${TARBALL_NAME}"
print_info "  SHA256:  ${checksum}"
print_info "  Checksum file: ${SHA256_NAME}"

print_success "Platform packaged successfully!"

