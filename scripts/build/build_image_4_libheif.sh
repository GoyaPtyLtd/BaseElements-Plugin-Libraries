#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="libheif"
ARCHIVE_NAME="libheif.tar.gz"

print_header "Starting ${LIBRARY_NAME} Build"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
MISSING_DEPS=()

# Check required libraries
if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]]; then
    MISSING_DEPS+=("Library: zlib (${OUTPUT_LIB}/zlib/libz.a)")
fi

if [[ ! -f "${OUTPUT_LIB}/libde265/libde265.a" ]]; then
    MISSING_DEPS+=("Library: libde265 (${OUTPUT_LIB}/libde265/libde265.a)")
fi

if [[ ! -f "${OUTPUT_LIB}/libturbojpeg/libjpeg.a" ]]; then
    MISSING_DEPS+=("Library: libjpeg (${OUTPUT_LIB}/libturbojpeg/libjpeg.a)")
fi

# Check required headers
if [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
    MISSING_DEPS+=("Headers: zlib (${OUTPUT_INCLUDE}/zlib)")
fi

if [[ ! -d "${OUTPUT_INCLUDE}/libde265" ]]; then
    MISSING_DEPS+=("Headers: libde265 (${OUTPUT_INCLUDE}/libde265)")
fi

if [[ ! -d "${OUTPUT_INCLUDE}/libturbojpeg" ]]; then
    MISSING_DEPS+=("Headers: libturbojpeg (${OUTPUT_INCLUDE}/libturbojpeg)")
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
    echo "  image_1_libturbojpeg (libturbojpeg)"
    echo "  image_2_libde265 (libde265)"
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

# Configure and build
interactive_prompt \
    "Ready to configure and build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}" \
    "Dependencies will be found from: ${OUTPUT_INCLUDE} and ${OUTPUT_LIB}"

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    export MACOSX_DEPLOYMENT_TARGET=10.15
    
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
    cmake -G "Unix Makefiles" --preset=release-noplugins -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=RELEASE \
        -DBUILD_SHARED_LIBS:BOOL=OFF -DWITH_REDUCED_VISIBILITY=OFF -DWITH_UNCOMPRESSED_CODEC=OFF \
		-DWITH_EXAMPLES=OFF -DBUILD_DOCUMENTATION=OFF \
        -DWITH_AOM_DECODER:BOOL=OFF -DWITH_AOM_ENCODER:BOOL=OFF \
        -DWITH_X265:BOOL=OFF -DWITH_LIBSHARPYUV:BOOL=OFF \
        -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib/" -DZLIB_LIBRARY="${OUTPUT_LIB}/zlib/libz.a" \
        -DLIBDE265_INCLUDE_DIR="${OUTPUT_INCLUDE}" -DLIBDE265_LIBRARY="${OUTPUT_LIB}/libde265/libde265.a" \
        -DJPEG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libturbojpeg/" -DJPEG_LIBRARY="${OUTPUT_LIB}/libturbojpeg/libjpeg.a" ./
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ CFLAGS="-fPIC" \
    cmake -G "Unix Makefiles" --preset=release-noplugins -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=RELEASE \
        -DBUILD_SHARED_LIBS:BOOL=OFF -DWITH_REDUCED_VISIBILITY=OFF -DWITH_UNCOMPRESSED_CODEC=OFF \
		-DWITH_EXAMPLES=OFF -DBUILD_DOCUMENTATION=OFF \
        -DWITH_AOM_DECODER:BOOL=OFF -DWITH_AOM_ENCODER:BOOL=OFF \
        -DWITH_X265:BOOL=OFF -DWITH_LIBSHARPYUV:BOOL=OFF \
        -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib/" -DZLIB_LIBRARY="${OUTPUT_LIB}/zlib/libz.a" \
        -DLIBDE265_INCLUDE_DIR="${OUTPUT_INCLUDE}" -DLIBDE265_LIBRARY="${OUTPUT_LIB}/libde265/libde265.a" \
        -DJPEG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libturbojpeg/" -DJPEG_LIBRARY="${OUTPUT_LIB}/libturbojpeg/libjpeg.a" ./
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make -j${JOBS}
make install

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Library: ${OUTPUT_LIB}/${LIBRARY_NAME}/${LIBRARY_NAME}.a"

cp -R "${PREFIX}/include/${LIBRARY_NAME}"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
