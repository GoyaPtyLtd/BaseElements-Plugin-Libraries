#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="curl"
ARCHIVE_NAME="curl.tar.gz"

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

if [[ ! -f "${OUTPUT_LIB}/libssh2/libssh2.a" ]]; then
    MISSING_DEPS+=("Library: libssh2 (${OUTPUT_LIB}/libssh2/libssh2.a)")
fi

if [[ ! -f "${OUTPUT_LIB}/nghttp2/libnghttp2.a" ]]; then
    MISSING_DEPS+=("Library: nghttp2 (${OUTPUT_LIB}/nghttp2/libnghttp2.a)")
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
    echo "  curl_3_libssh (libssh2)"
    echo "  curl_4_nghttp2 (nghttp2)"
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
mkdir -p "${BUILD_DIR}/lib"
PREFIX="${BUILD_DIR}"

# Set up dependency paths
ZLIB_PREFIX="${OUTPUT_SRC}/zlib/_build"
LIBSSH2_PREFIX="${OUTPUT_SRC}/libssh2/_build"
NGHTTP2_PREFIX="${OUTPUT_SRC}/nghttp2/_build"
OPENSSL_PREFIX="${OUTPUT_SRC}/openssl/_build"

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
    OPENSSL_PREFIX_x86_64="${OUTPUT_SRC}/openssl/_build_x86_64"
    
    print_info "Building x86_64 architecture..."
    CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
    CPPFLAGS="-I${OUTPUT_INCLUDE} -I${OUTPUT_INCLUDE}/openssl" \
    LDFLAGS="-L${OUTPUT_LIB}/${LIBRARY_NAME}" LIBS="-ldl" \
    ./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
        --without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 --without-nghttp3 --without-librtmp --disable-unix-sockets \
        --with-zlib=${ZLIB_PREFIX} --with-openssl=${OPENSSL_PREFIX_x86_64} --with-libssh2=${LIBSSH2_PREFIX} --with-nghttp2=${NGHTTP2_PREFIX} \
        --prefix="${PREFIX_x86_64}" \
        --host="${HOST}"
    
    make -j${JOBS}
    make install
    make -s distclean
    
    # Build arm64
    BUILD_DIR_arm64="${OUTPUT_SRC}/${LIBRARY_NAME}/_build_arm64"
    PREFIX_arm64="${BUILD_DIR_arm64}"
    mkdir -p "${BUILD_DIR_arm64}"
    OPENSSL_PREFIX_arm64="${OUTPUT_SRC}/openssl/_build_arm64"
    
    print_info "Building arm64 architecture..."
    CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
    CPPFLAGS="-I${OUTPUT_INCLUDE} -I${OUTPUT_INCLUDE}/openssl" \
    LDFLAGS="-L${OUTPUT_LIB}/${LIBRARY_NAME}" LIBS="-ldl" \
    ./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
        --without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 --without-nghttp3 --without-librtmp --disable-unix-sockets \
        --with-zlib=${ZLIB_PREFIX} --with-openssl=${OPENSSL_PREFIX_arm64} --with-libssh2=${LIBSSH2_PREFIX} --with-nghttp2=${NGHTTP2_PREFIX} \
        --prefix="${PREFIX_arm64}" \
        --host="${HOST}"
    
    make -j${JOBS}
    make install
    make -s distclean
    
    # Create universal library with lipo
    print_info "Creating universal library..."
    lipo -create "${PREFIX_x86_64}/lib/libcurl.a" "${PREFIX_arm64}/lib/libcurl.a" -output "${PREFIX}/lib/libcurl.a"
    
	# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others
    # TODO also investigate libidn which is also in podofo
	
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    ./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
        --without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 \
        --with-zlib=${ZLIB_PREFIX} --with-openssl=${OPENSSL_PREFIX} --with-libssh2=${LIBSSH2_PREFIX} \
        --prefix="${PREFIX}"
    
    print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
    make -j${JOBS}
    make install
fi

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Library: ${OUTPUT_LIB}/${LIBRARY_NAME}/libcurl.a"

if [[ $OS = 'Darwin' ]]; then
    cp -R "${PREFIX_x86_64}/include"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
else
    cp -R "${PREFIX}/include/curl"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
fi

cp "${PREFIX}/lib/libcurl.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
