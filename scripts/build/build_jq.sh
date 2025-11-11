#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="jq"
ARCHIVE_NAME="jq.tar.gz"

print_header "Starting ${LIBRARY_NAME} Build"

# Clean and create output directories (ensures they exist and are empty)
interactive_prompt \
    "Ready to clean and create output directories for ${LIBRARY_NAME}" \
    "Will remove and recreate: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}" \
    "Will remove and recreate: ${OUTPUT_LIB}/${LIBRARY_NAME}" \
    "Will remove and recreate: ${OUTPUT_SRC}/${LIBRARY_NAME}"

rm -rf "${OUTPUT_INCLUDE}/${LIBRARY_NAME}"
rm -rf "${OUTPUT_LIB}/${LIBRARY_NAME}"
rm -rf "${OUTPUT_SRC}/${LIBRARY_NAME}"

mkdir -p "${OUTPUT_INCLUDE}/${LIBRARY_NAME}"
mkdir -p "${OUTPUT_LIB}/${LIBRARY_NAME}"
mkdir -p "${OUTPUT_SRC}/${LIBRARY_NAME}"

# Extract source to output/platforms/${PLATFORM}/src/
interactive_prompt \
    "Ready to extract source archive" \
    "Archive: ${SOURCE_ARCHIVES}/${ARCHIVE_NAME}" \
    "Destination: ${OUTPUT_SRC}/${LIBRARY_NAME}"

cd "${OUTPUT_SRC}/${LIBRARY_NAME}"
tar -xf "${SOURCE_ARCHIVES}/${ARCHIVE_NAME}" --strip-components=1

# Create build directory
BUILD_DIR="${OUTPUT_SRC}/${LIBRARY_NAME}/_build"
mkdir -p "${BUILD_DIR}"
PREFIX="${BUILD_DIR}"

# Configure
interactive_prompt \
    "Ready to configure ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}"

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build (arm64 + x86_64)
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
    ./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared \
        --enable-all-static --enable-pthread-tls --without-oniguruma \
        --prefix="${PREFIX}"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ CFLAGS="-fPIC" \
    ./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared \
        --enable-all-static --enable-pthread-tls --without-oniguruma \
        --prefix="${PREFIX}"
fi

# Build
interactive_prompt \
    "Ready to build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Jobs: ${JOBS}" \
    "Build prefix: ${PREFIX}" \
    "Built library: ${PREFIX}/lib/lib${LIBRARY_NAME}.a"

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
if [[ $QUIET_BUILD -eq 1 ]]; then
    make -j${JOBS} -s
    make install -s
else
    make -j${JOBS}
    make install
fi

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Library: ${OUTPUT_LIB}/${LIBRARY_NAME}/lib${LIBRARY_NAME}.a"

# jq requires version.h file, but doesn't put it into the prefix
cp src/version.h "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/"
cp -R "${PREFIX}/include"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/lib${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
