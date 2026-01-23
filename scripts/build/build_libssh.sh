#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="libssh2"
ARCHIVE_NAME="libssh.tar.gz"

print_header "Starting BE Library Build : ${LIBRARY_NAME}"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
SCRIPT_DIR="$(dirname "$0")"
MISSING_DEPS=()

if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
	print_info "Missing dependency : zlib..."
	print_info "Start build : zlib..."
	"${SCRIPT_DIR}/build_zlib.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/openssl/libssl.a" ]] || [[ ! -f "${OUTPUT_LIB}/openssl/libcrypto.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/openssl" ]]; then
	print_info "Missing dependency : openssl..."
	print_info "Start build : openssl..."
	"${SCRIPT_DIR}/build_openssl.sh"
fi

if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
    MISSING_DEPS+=("zlib")
fi
if [[ ! -f "${OUTPUT_LIB}/openssl/libssl.a" ]] || [[ ! -f "${OUTPUT_LIB}/openssl/libcrypto.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/openssl" ]]; then
    MISSING_DEPS+=("openssl")
fi

# Report missing dependencies
if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    print_error "ERROR: Missing dependencies for ${LIBRARY_NAME}:"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - ${dep}"
    done
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
ZLIB_PREFIX="${OUTPUT_SRC}/zlib/_build"
if [[ $OS = 'Darwin' ]]; then
    # On macOS, use arm64 build directory which has both lib and include
    # The libssh2 configure script needs a prefix with both subdirectories
    OPENSSL_PREFIX="${OUTPUT_SRC}/openssl/_build_arm64"
else
    OPENSSL_PREFIX="${OUTPUT_SRC}/openssl/_build"
fi

# Configure and build
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    # Use universal OpenSSL libs from _build/lib, but prefix points to _build_arm64 for headers
    OPENSSL_UNIVERSAL_LIB="${OUTPUT_SRC}/openssl/_build/lib"
    CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" \
    CPPFLAGS="-I${OUTPUT_INCLUDE}/zlib -I${OUTPUT_INCLUDE}/openssl"  \
    LDFLAGS="-L${OUTPUT_LIB}/zlib -L${OPENSSL_UNIVERSAL_LIB}" LIBS="-ldl" \
    ./configure --silent --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
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
    ./configure --silent --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
        --with-libz --with-libz-prefix=${ZLIB_PREFIX} \
        --with-crypto=openssl --with-libssl-prefix=${OPENSSL_PREFIX} \
        --prefix="${PREFIX}"
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make --silent -j${JOBS}
make --silent install

# Copy headers and libraries
cp -R "${PREFIX}/include"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
