#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="jq"
ARCHIVE_NAME="jq.tar.gz"

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

# Configure
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build (arm64 + x86_64)
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -Wno-unused-but-set-variable -Wno-unused-variable" \
    ./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared \
        --enable-all-static --enable-pthread-tls --without-oniguruma \
        --prefix="${PREFIX}"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ CFLAGS="-fPIC" \
    ./configure --silent --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared \
        --enable-all-static --enable-pthread-tls --without-oniguruma \
        --prefix="${PREFIX}"
fi

# Build
print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make -j${JOBS}
make install

# Copy headers and libraries
# jq requires version.h file, but doesn't put it into the prefix
cp src/version.h "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/"
cp -R "${PREFIX}/include"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/lib${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
