#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="libxml"
ARCHIVE_NAME="libxml.tar.xz"

print_header "Starting BE Library Build : ${LIBRARY_NAME}"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
SCRIPT_DIR="$(dirname "$0")"

# Check required library
if [[ ! -f "${OUTPUT_LIB}/iconv/libiconv.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/iconv" ]]; then
	print_info "Missing dependency : zlib..."
	print_info "Start build : zlib..."
	"${SCRIPT_DIR}/build_zlib.sh"
fi

# Report missing dependencies
if [[ ! -f "${OUTPUT_LIB}/iconv/libiconv.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/iconv" ]]; then
    print_error "ERROR: Missing dependencies for ${LIBRARY_NAME}:"
    echo "  - iconv"
    exit 1
fi

print_success "All dependencies found for ${LIBRARY_NAME}"

# Clean and create output directories (ensures they exist and are empty)
rm -rf "${OUTPUT_INCLUDE}/${LIBRARY_NAME}"
rm -rf "${OUTPUT_LIB}/${LIBRARY_NAME}"
rm -rf "${OUTPUT_SRC}/${LIBRARY_NAME}"

mkdir -p "${OUTPUT_INCLUDE}/${LIBRARY_NAME}"
mkdir -p "${OUTPUT_LIB}/${LIBRARY_NAME}"
mkdir -p "${OUTPUT_SRC}/${LIBRARY_NAME}"

# Extract source to output/platforms/${PLATFORM}/src/
cd "${OUTPUT_SRC}/${LIBRARY_NAME}"
tar -xf "${SOURCE_ARCHIVES}/${ARCHIVE_NAME}" --strip-components=1

# Create build directory
BUILD_DIR="${OUTPUT_SRC}/${LIBRARY_NAME}/_build"
mkdir -p "${BUILD_DIR}"
PREFIX="${BUILD_DIR}"

# Set up dependency paths
ICONV_PREFIX="${OUTPUT_SRC}/iconv/_build"

# Configure and build
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
    ./configure --silent --disable-shared --with-threads --with-sax1 --without-python --without-zlib --without-lzma \
        --with-iconv="${ICONV_PREFIX}" \
        --prefix="${PREFIX}"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    CFLAGS="-fPIC" \
    ./configure --silent --disable-shared --with-threads --with-sax1 --without-python --without-zlib --without-lzma \
        --prefix="${PREFIX}"
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make --silent -j${JOBS}
make --silent install

# Fix header includes on macOS (affects XCode compilation - makes it use our iconv instead of system iconv)
if [[ $OS = 'Darwin' ]]; then
    print_info "Fixing iconv header includes for macOS..."
    sed -i '' -e 's|#include <iconv/iconv\.h\>|#include <iconv\.h>|g' "${PREFIX}/include/libxml2/libxml/encoding.h"
fi

# Copy headers and libraries
cp -R "${PREFIX}/include/libxml2/libxml"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/libxml2.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
