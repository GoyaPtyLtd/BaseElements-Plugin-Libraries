#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

# Skip building on Linux (not needed)
if [[ $OS = 'Linux' ]]; then
    print_info "Skipping ${LIBRARY_NAME} build on Linux (not needed)"
    exit 0
fi

LIBRARY_NAME="libopenjp2"
ARCHIVE_NAME="libopenjp2.tar.gz"

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
cd "${BUILD_DIR}"
PREFIX="${BUILD_DIR}"

# Configure and build
interactive_prompt \
    "Ready to configure and build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}"

# macOS universal build
print_info "Configuring for macOS (universal: arm64 + x86_64)..."
CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_SHARED_LIBS:BOOL=OFF \
    -DCMAKE_IGNORE_PATH=/usr/local/lib/ \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_LIBRARY_PATH:path="${OUTPUT_LIB}" -DCMAKE_INCLUDE_PATH:path="${OUTPUT_INCLUDE}" \
    -DBUILD_CODEC:BOOL=OFF -DBUILD_JPIPSERVER:BOOL=OFF -DBUILD_JPIPCLIENT:BOOL=OFF \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" ../

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."

# Build only the library target to avoid linking executables against Homebrew libraries
cmake --build . --target openjp2 -- -j${JOBS}

# Install only the library (skip make install which rebuilds all targets including executables)
# Copy the library from build location to PREFIX
mkdir -p "${PREFIX}/lib"
cp "${BUILD_DIR}/bin/libopenjp2.a" "${PREFIX}/lib/libopenjp2.a"

# Copy headers manually (no generated headers for openjp2)
mkdir -p "${PREFIX}/include/openjpeg-2.5"
cp "${OUTPUT_SRC}/${LIBRARY_NAME}/src/lib/openjp2"/*.h "${PREFIX}/include/openjpeg-2.5/"

# Copy headers and libraries to final destination
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Library: ${OUTPUT_LIB}/${LIBRARY_NAME}/${LIBRARY_NAME}.a"

cp -R "${PREFIX}/include/openjpeg-2.5"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
