#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="openssl"
ARCHIVE_NAME="openssl.tar.gz"

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

# Configure and build (special handling for macOS universal build)
interactive_prompt \
    "Ready to configure and build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}"

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build: build x86_64 and arm64 separately, then lipo together
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    
    # Build x86_64
    BUILD_DIR_x86_64="${OUTPUT_SRC}/${LIBRARY_NAME}/_build_x86_64"
    PREFIX_x86_64="${BUILD_DIR_x86_64}"
    mkdir -p "${BUILD_DIR_x86_64}"
    
    print_info "Building x86_64 architecture..."
    CFLAGS="-mmacosx-version-min=10.15" \
    ./Configure d--silent arwin64-x86_64-cc no-shared no-docs no-tests \
        --prefix="${PREFIX_x86_64}"
    
    make --silent -j${JOBS}
    make --silent install
    make --silent distclean
    
    # Build arm64
    BUILD_DIR_arm64="${OUTPUT_SRC}/${LIBRARY_NAME}/_build_arm64"
    PREFIX_arm64="${BUILD_DIR_arm64}"
    mkdir -p "${BUILD_DIR_arm64}"
    
    print_info "Building arm64 architecture..."
    CFLAGS="-mmacosx-version-min=10.15" \
    ./Configure --silent darwin64-arm64-cc no-shared no-docs no-tests \
        --prefix="${PREFIX_arm64}"
    
    make --silent -j${JOBS}
    make --silent install
    make --silent distclean
    
    # Create universal libraries with lipo
    print_info "Creating universal libraries..."
    mkdir -p "${PREFIX}/lib"
    lipo -create "${PREFIX_x86_64}/lib/libcrypto.a" "${PREFIX_arm64}/lib/libcrypto.a" -output "${PREFIX}/lib/libcrypto.a"
    lipo -create "${PREFIX_x86_64}/lib/libssl.a" "${PREFIX_arm64}/lib/libssl.a" -output "${PREFIX}/lib/libssl.a"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    ./Configure --silent linux-generic64 no-shared no-docs no-tests \
        --prefix="${PREFIX}"
    
    print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
    make --silent -j${JOBS}
    make --silent install_sw
fi

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Libraries: ${OUTPUT_LIB}/${LIBRARY_NAME}/libcrypto.a and libssl.a"

if [[ $OS = 'Darwin' ]]; then
    cp -R "${PREFIX_x86_64}/include/openssl"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
else
    cp -R "${PREFIX}/include/openssl"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
fi

cp "${PREFIX}/lib/libcrypto.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libssl.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
