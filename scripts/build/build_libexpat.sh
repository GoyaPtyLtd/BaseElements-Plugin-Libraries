#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="libexpat"
ARCHIVE_NAME="expat.tar.xz"

print_header "Starting BE Library Build : ${LIBRARY_NAME}"

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

# Configure and build
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring ${LIBRARY_NAME} for macOS (universal: arm64 + x86_64)..."
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
    ./configure --silent --disable-shared --prefix="${PREFIX}"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring ${LIBRARY_NAME} for Linux..."
    CC=clang CXX=clang++ \
    CFLAGS="-fPIC" \
    ./configure --silent --disable-shared --prefix="${PREFIX}"
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make --silent -j${JOBS}
make --silent install

# Copy headers and libraries
cp -R "${PREFIX}/include"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
