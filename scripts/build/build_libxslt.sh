#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="libxslt"
ARCHIVE_NAME="libxslt.tar.xz"

print_header "Starting BE Library Build : ${LIBRARY_NAME}"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
MISSING_DEPS=()

# Check required library
if [[ ! -f "${OUTPUT_LIB}/libxml/libxml2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libxml" ]]; then
	print_info "Missing dependencies : libxml..."
	print_info "Start build : libxml..."
	"${SCRIPT_DIR}/build_libxml.sh"
fi

# Report missing dependencies
if [[ ! -f "${OUTPUT_LIB}/libxml/libxml2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libxml" ]]; then
    print_error "ERROR: Missing dependencies for ${LIBRARY_NAME}:"
    echo "  - libxml"
    exit 1
fi

print_success "All dependencies found for ${LIBRARY_NAME}"

# Clean and create output directories (ensures they exist and are empty)
rm -rf "${OUTPUT_INCLUDE}/${LIBRARY_NAME}"
rm -rf "${OUTPUT_INCLUDE}/libexslt"
rm -rf "${OUTPUT_LIB}/${LIBRARY_NAME}"
rm -rf "${OUTPUT_SRC}/${LIBRARY_NAME}"

mkdir -p "${OUTPUT_INCLUDE}/${LIBRARY_NAME}"
mkdir -p "${OUTPUT_INCLUDE}/libexslt"
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
LIBXML_PREFIX="${OUTPUT_SRC}/libxml/_build"

# Configure and build
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
    ./configure --silent --disable-shared --without-python --without-crypto \
        --with-libxml-prefix="${LIBXML_PREFIX}" \
        --prefix="${PREFIX}"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    CFLAGS="-fPIC" \
    ./configure --silent --disable-shared --without-python --without-crypto \
        --with-libxml-prefix="${LIBXML_PREFIX}" \
        --prefix="${PREFIX}"
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make --silent -j${JOBS}
make --silent install

# Copy headers and libraries
cp -R "${PREFIX}/include/libxslt"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp -R "${PREFIX}/include/libexslt"/* "${OUTPUT_INCLUDE}/libexslt/" 2>/dev/null || true
cp "${PREFIX}/lib/libxslt.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libexslt.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
