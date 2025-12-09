#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="curl"
ARCHIVE_NAME="curl.tar.gz"

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
if [[ ! -f "${OUTPUT_LIB}/libssh2/libssh2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libssh2" ]]; then
	print_info "Missing dependency : libssh..."
	print_info "Start build : libssh..."
	"${SCRIPT_DIR}/build_libssh.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/nghttp2/nghttp2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/nghttp2" ]]; then
	print_info "Missing dependency : nghttp2..."
	print_info "Start build : nghttp2..."
	"${SCRIPT_DIR}/build_nghttp2.sh"
fi

if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
    MISSING_DEPS+=("zlib")
fi
if [[ ! -f "${OUTPUT_LIB}/openssl/libssl.a" ]] || [[ ! -f "${OUTPUT_LIB}/openssl/libcrypto.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/openssl" ]]; then
    MISSING_DEPS+=("openssl")
fi
if [[ ! -f "${OUTPUT_LIB}/libssh2/libssh2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libssh2" ]]; then
    MISSING_DEPS+=("libssh2")
fi
if [[ ! -f "${OUTPUT_LIB}/nghttp2/nghttp2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/nghttp2" ]]; then
    MISSING_DEPS+=("nghttp2")
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
mkdir -p "${BUILD_DIR}/lib"
PREFIX="${BUILD_DIR}"

# Set up dependency paths
ZLIB_PREFIX="${OUTPUT_SRC}/zlib/_build"
LIBSSH2_PREFIX="${OUTPUT_SRC}/libssh2/_build"
NGHTTP2_PREFIX="${OUTPUT_SRC}/nghttp2/_build"
OPENSSL_PREFIX="${OUTPUT_SRC}/openssl/_build"

# Configure and build (special handling for macOS universal build)
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build: build x86_64 and arm64 separately, then lipo together
    print_info "Configuring ${LIBRARY_NAME} for macOS (universal: arm64 + x86_64)..."
    
    # Build x86_64
    BUILD_DIR_x86_64="${OUTPUT_SRC}/${LIBRARY_NAME}/_build_x86_64"
    PREFIX_x86_64="${BUILD_DIR_x86_64}"
    mkdir -p "${BUILD_DIR_x86_64}"
    OPENSSL_PREFIX_x86_64="${OUTPUT_SRC}/openssl/_build_x86_64"
    
    print_info "Building ${LIBRARY_NAME} x86_64 architecture..."
    CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
    CPPFLAGS="-I${OUTPUT_INCLUDE} -I${OUTPUT_INCLUDE}/openssl" \
    LDFLAGS="-L${OUTPUT_LIB}/${LIBRARY_NAME}" LIBS="-ldl" \
    ./configure --silent --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
        --without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 --without-nghttp3 --without-librtmp --disable-unix-sockets \
        --with-zlib=${ZLIB_PREFIX} --with-openssl=${OPENSSL_PREFIX_x86_64} --with-libssh2=${LIBSSH2_PREFIX} --with-nghttp2=${NGHTTP2_PREFIX} \
        --prefix="${PREFIX_x86_64}" \
        --host="x86_64-apple-darwin"
    
    make --silent -j${JOBS}
    make --silent install
    make --silent distclean
    
    # Build arm64
    BUILD_DIR_arm64="${OUTPUT_SRC}/${LIBRARY_NAME}/_build_arm64"
    PREFIX_arm64="${BUILD_DIR_arm64}"
    mkdir -p "${BUILD_DIR_arm64}"
    OPENSSL_PREFIX_arm64="${OUTPUT_SRC}/openssl/_build_arm64"
    
    print_info "Building ${LIBRARY_NAME} arm64 architecture..."
    CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
    CPPFLAGS="-I${OUTPUT_INCLUDE} -I${OUTPUT_INCLUDE}/openssl" \
    LDFLAGS="-L${OUTPUT_LIB}/${LIBRARY_NAME}" LIBS="-ldl" \
    ./configure --silent --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
        --without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 --without-nghttp3 --without-librtmp --disable-unix-sockets \
        --with-zlib=${ZLIB_PREFIX} --with-openssl=${OPENSSL_PREFIX_arm64} --with-libssh2=${LIBSSH2_PREFIX} --with-nghttp2=${NGHTTP2_PREFIX} \
        --prefix="${PREFIX_arm64}" \
        --host="arm64-apple-darwin"
    
    make --silent -j${JOBS}
    make --silent install
    make --silent distclean
    
    # Create universal library with lipo
    print_info "Creating ${LIBRARY_NAME} universal library..."
    mkdir -p "${PREFIX}/lib"
    mkdir -p "${PREFIX}/include/curl"
    cp -R "${PREFIX_x86_64}/include/curl"/* "${PREFIX}/include/curl/"

    lipo -create "${PREFIX_x86_64}/lib/libcurl.a" "${PREFIX_arm64}/lib/libcurl.a" -output "${PREFIX}/lib/libcurl.a"
  
	# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others
    # TODO also investigate libidn which is also in podofo
	
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring ${LIBRARY_NAME} for Linux..."
    CC=clang CXX=clang++ \
    ./configure --silent --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
        --without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 --without-nghttp3 --without-librtmp \
        --with-zlib=${ZLIB_PREFIX} --with-openssl=${OPENSSL_PREFIX} --with-libssh2=${LIBSSH2_PREFIX} \
        --prefix="${PREFIX}"
    
    print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
    make --silent -j${JOBS}
    make --silent install
fi

# Copy headers and libraries
cp -R "${PREFIX}/include/curl"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/libcurl.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
