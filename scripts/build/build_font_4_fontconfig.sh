#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="fontconfig"
ARCHIVE_NAME="fontconfig.tar.gz"

print_header "Starting ${LIBRARY_NAME} Build"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
MISSING_DEPS=()

# Check required libraries
if [[ ! -f "${OUTPUT_LIB}/libexpat/libexpat.a" ]]; then
    MISSING_DEPS+=("Library: libexpat (${OUTPUT_LIB}/libexpat/libexpat.a)")
fi

if [[ ! -f "${OUTPUT_LIB}/freetype2/libfreetype.a" ]]; then
    MISSING_DEPS+=("Library: libfreetype (${OUTPUT_LIB}/freetype2/libfreetype.a)")
fi

# Check required headers
if [[ ! -d "${OUTPUT_INCLUDE}/libexpat" ]]; then
    MISSING_DEPS+=("Headers: libexpat (${OUTPUT_INCLUDE}/libexpat)")
fi

if [[ ! -d "${OUTPUT_INCLUDE}/freetype2" ]]; then
    MISSING_DEPS+=("Headers: freetype2 (${OUTPUT_INCLUDE}/freetype2)")
fi

# Report missing dependencies
if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    print_error "ERROR: Missing dependencies for ${LIBRARY_NAME}:"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - ${dep}"
    done
    echo ""
    echo "Please build dependencies first:"
    echo "  font_1_libunistring (libunistring)"
    echo "  font_2_libexpat (libexpat)"
    echo "  font_3_freetype (freetype2)"
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
LIBEXPAT_PREFIX="${OUTPUT_SRC}/libexpat/_build"

# Configure and build
interactive_prompt \
    "Ready to configure and build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}" \
    "Dependencies will be found from: ${OUTPUT_INCLUDE} and ${OUTPUT_LIB}"

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
    LDFLAGS="-L${OUTPUT_LIB}" \
    FREETYPE_CFLAGS="-I${OUTPUT_INCLUDE}/freetype2" FREETYPE_LIBS="-L${OUTPUT_LIB}/freetype2 -lfreetype" \
    ./configure --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
        --with-expat=${LIBEXPAT_PREFIX} \
        --prefix="${PREFIX}"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    CFLAGS="-fPIC" \
    LDFLAGS="-L${OUTPUT_LIB}" \
    FREETYPE_CFLAGS="-I${OUTPUT_INCLUDE}/freetype2" FREETYPE_LIBS="-L${OUTPUT_LIB}/freetype2 -lfreetype" \
    ./configure --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
        --with-expat=${LIBEXPAT_PREFIX} \
        --prefix="${PREFIX}"
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make -j${JOBS}
make install

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Library: ${OUTPUT_LIB}/${LIBRARY_NAME}/lib${LIBRARY_NAME}.a"

cp -R "${PREFIX}/include/fontconfig"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/lib${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
