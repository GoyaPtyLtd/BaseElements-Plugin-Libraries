#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="libssh2"
ARCHIVE_NAME="libssh.tar.gz"

print_header "Starting ${LIBRARY_NAME} Build"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
MISSING_DEPS=()

# Check required libraries
if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]]; then
    MISSING_DEPS+=("Library: zlib (${OUTPUT_LIB}/zlib/libz.a)")
fi

if [[ ! -f "${OUTPUT_LIB}/openssl/libssl.a" ]]; then
    MISSING_DEPS+=("Library: libssl (${OUTPUT_LIB}/openssl/libssl.a)")
fi

if [[ ! -f "${OUTPUT_LIB}/openssl/libcrypto.a" ]]; then
    MISSING_DEPS+=("Library: libcrypto (${OUTPUT_LIB}/openssl/libcrypto.a)")
fi

# Check required headers
if [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
    MISSING_DEPS+=("Headers: zlib (${OUTPUT_INCLUDE}/zlib)")
fi

if [[ ! -d "${OUTPUT_INCLUDE}/openssl" ]]; then
    MISSING_DEPS+=("Headers: openssl (${OUTPUT_INCLUDE}/openssl)")
fi

# Report missing dependencies
if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    print_error "ERROR: Missing dependencies for ${LIBRARY_NAME}:"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - ${dep}"
    done
    echo ""
    echo "Please build dependencies first:"
    echo "  curl_1_zlib (zlib)"
    echo "  curl_2_openssl (openssl)"
    exit 1
fi

print_success "All dependencies found for ${LIBRARY_NAME}"

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

# Set up dependency paths
ZLIB_PREFIX="${OUTPUT_SRC}/zlib/_build"
if [[ $OS = 'Darwin' ]]; then
    # On macOS, use arm64 build directory which has both lib and include
    # The libssh2 configure script needs a prefix with both subdirectories
    OPENSSL_PREFIX="${OUTPUT_SRC}/openssl/_build_arm64"
else
    OPENSSL_PREFIX="${OUTPUT_SRC}/openssl/_build"
fi

# Configure and build
interactive_prompt \
    "Ready to configure and build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}" \
    "Dependencies will be found from: ${OUTPUT_INCLUDE} and ${OUTPUT_LIB}"

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    # Use universal OpenSSL libs from _build/lib, but prefix points to _build_arm64 for headers
    OPENSSL_UNIVERSAL_LIB="${OUTPUT_SRC}/openssl/_build/lib"
    CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" \
    CPPFLAGS="-I${OUTPUT_INCLUDE}/zlib -I${OUTPUT_INCLUDE}/openssl"  \
    LDFLAGS="-L${OUTPUT_LIB}/zlib -L${OPENSSL_UNIVERSAL_LIB}" LIBS="-ldl" \
    ./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
        --with-libz --with-libz-prefix=${ZLIB_PREFIX} \
        --with-crypto=openssl --with-libssl-prefix=${OPENSSL_PREFIX} \
        --prefix="${PREFIX}"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    CFLAGS="-fPIC" \
    CPPFLAGS="-I${OUTPUT_INCLUDE}/zlib"  \
    LDFLAGS="-L${OUTPUT_LIB}/zlib" LIBS="-ldl" \
    ./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
        --with-libz --with-libz-prefix=${ZLIB_PREFIX} \
        --with-crypto=openssl --with-libssl-prefix=${OPENSSL_PREFIX} \
        --prefix="${PREFIX}"
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make -j${JOBS}
make install

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Library: ${OUTPUT_LIB}/${LIBRARY_NAME}/${LIBRARY_NAME}.a"

cp -R "${PREFIX}/include"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
