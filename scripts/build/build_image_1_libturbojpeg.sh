#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="libturbojpeg"
ARCHIVE_NAME="libturbojpeg.tar.gz"

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

# Configure and build
interactive_prompt \
    "Ready to configure and build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}"

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build (separate arm64 and x86_64 builds, then lipo)
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    
    # Build arm64
    BUILD_DIR_arm64="${BUILD_DIR}_arm64"
    mkdir -p "${BUILD_DIR_arm64}"
    PREFIX_arm64="${BUILD_DIR_arm64}"
    
    echo "set(CMAKE_SYSTEM_NAME Darwin)" > toolchain.cmake
    echo "set(CMAKE_SYSTEM_PROCESSOR aarch64)" >> toolchain.cmake
    
    CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
    LDFLAGS="-ld_classic" \
    cmake --fresh -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX="${PREFIX_arm64}" ./
    
    print_info "Building ${LIBRARY_NAME} for arm64 (${JOBS} parallel jobs)..."
    make -j${JOBS}
    make install
    
    # Build x86_64
    BUILD_DIR_x86_64="${BUILD_DIR}_x86_64"
    mkdir -p "${BUILD_DIR_x86_64}"
    PREFIX_x86_64="${BUILD_DIR_x86_64}"
    
    echo "set(CMAKE_SYSTEM_NAME Darwin)" > toolchain.cmake
    echo "set(CMAKE_SYSTEM_PROCESSOR x86_64)" >> toolchain.cmake
    
    CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
    LDFLAGS="-ld_classic" \
    cmake --fresh -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX="${PREFIX_x86_64}" ./
    
    print_info "Building ${LIBRARY_NAME} for x86_64 (${JOBS} parallel jobs)..."
    make -j${JOBS}
    make install
    
    # Create universal binaries
    mkdir -p "${PREFIX}/lib"
    print_info "Creating universal binaries..."
    lipo -create "${PREFIX_x86_64}/lib/libturbojpeg.a" "${PREFIX_arm64}/lib/libturbojpeg.a" -output "${PREFIX}/lib/libturbojpeg.a"
    lipo -create "${PREFIX_x86_64}/lib/libjpeg.a" "${PREFIX_arm64}/lib/libjpeg.a" -output "${PREFIX}/lib/libjpeg.a"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_SHARED_LIBS=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_IGNORE_PATH=/usr/lib/x86_64-linux-gnu/ \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" ./
    
    print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
    make -j${JOBS}
    make install
fi

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Libraries: ${OUTPUT_LIB}/${LIBRARY_NAME}/libturbojpeg.a and libjpeg.a"

if [[ $OS = 'Darwin' ]]; then
    cp -R "${PREFIX_x86_64}/include"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
else
    cp -R "${PREFIX}/include"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
fi

cp "${PREFIX}/lib/libturbojpeg.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libjpeg.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
