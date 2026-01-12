#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="Poco"
ARCHIVE_NAME="poco.tar.gz"

print_header "Starting BE Library Build : ${LIBRARY_NAME}"

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

# Configure and build
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build: build x86_64 and arm64 separately, then lipo together
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    
    # Build x86_64
    BUILD_DIR_x86_64="${OUTPUT_SRC}/${LIBRARY_NAME}/_build_x86_64"
    PREFIX_x86_64="${BUILD_DIR_x86_64}"
    mkdir -p "${BUILD_DIR_x86_64}"
    
    print_info "Building ${LIBRARY_NAME} x86_64 architecture..."
    ./configure --cflags="-mmacosx-version-min=10.15" \
        --prefix="${PREFIX_x86_64}" \
        --no-sharedlibs --static --poquito --no-tests --no-samples \
        --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
        --include-path="${OUTPUT_INCLUDE}" --library-path="${OUTPUT_LIB}/${LIBRARY_NAME}"
    
    make -j${JOBS} POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=x86_64 POCO_TARGET_OSARCH=x86_64
    make install POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=x86_64 POCO_TARGET_OSARCH=x86_64
    make distclean
    
    # Build arm64
    BUILD_DIR_arm64="${OUTPUT_SRC}/${LIBRARY_NAME}/_build_arm64"
    PREFIX_arm64="${BUILD_DIR_arm64}"
    mkdir -p "${BUILD_DIR_arm64}"
    
    print_info "Building ${LIBRARY_NAME} arm64 architecture..."
    ./configure --cflags="-mmacosx-version-min=10.15" \
        --prefix="${PREFIX_arm64}" \
        --no-sharedlibs --static --poquito --no-tests --no-samples \
        --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
        --include-path="${OUTPUT_INCLUDE}" --library-path="${OUTPUT_LIB}/${LIBRARY_NAME}"
    
    make -j${JOBS} POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=arm64 POCO_TARGET_OSARCH=arm64
    make install POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=arm64 POCO_TARGET_OSARCH=arm64
    make distclean
    
    # Create universal libraries with lipo
    print_info "Creating ${LIBRARY_NAME} universal libraries..."
    mkdir -p "${PREFIX}/lib"
    mkdir -p "${PREFIX}/include/Poco"
    cp -R "${PREFIX_x86_64}/include/Poco"/* "${PREFIX}/include/Poco/"
    
    lipo -create "${PREFIX_x86_64}/lib/libPocoCrypto.a" "${PREFIX_arm64}/lib/libPocoCrypto.a" -output "${PREFIX}/lib/libPocoCrypto.a"
    lipo -create "${PREFIX_x86_64}/lib/libPocoFoundation.a" "${PREFIX_arm64}/lib/libPocoFoundation.a" -output "${PREFIX}/lib/libPocoFoundation.a"
    lipo -create "${PREFIX_x86_64}/lib/libPocoJSON.a" "${PREFIX_arm64}/lib/libPocoJSON.a" -output "${PREFIX}/lib/libPocoJSON.a"
    lipo -create "${PREFIX_x86_64}/lib/libPocoNet.a" "${PREFIX_arm64}/lib/libPocoNet.a" -output "${PREFIX}/lib/libPocoNet.a"
    lipo -create "${PREFIX_x86_64}/lib/libPocoPDF.a" "${PREFIX_arm64}/lib/libPocoPDF.a" -output "${PREFIX}/lib/libPocoPDF.a"
    lipo -create "${PREFIX_x86_64}/lib/libPocoXML.a" "${PREFIX_arm64}/lib/libPocoXML.a" -output "${PREFIX}/lib/libPocoXML.a"
    lipo -create "${PREFIX_x86_64}/lib/libPocoUtil.a" "${PREFIX_arm64}/lib/libPocoUtil.a" -output "${PREFIX}/lib/libPocoUtil.a"
    lipo -create "${PREFIX_x86_64}/lib/libPocoZip.a" "${PREFIX_arm64}/lib/libPocoZip.a" -output "${PREFIX}/lib/libPocoZip.a"
        
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    # Explicitly unset CFLAGS/CXXFLAGS/ARCHFLAGS to prevent macOS-specific -arch flags from being inherited
    # Poco's build system (including PCRE2) will pick up these environment variables
    # ARCHFLAGS is particularly problematic as Poco's Linux config file incorrectly sets it to -arch
    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
    unset ARCHFLAGS
    
    print_info "Configuring ${LIBRARY_NAME} for Linux..."
    CC=clang CXX=clang++ \
    ARCHFLAGS="" \
    CFLAGS="-fPIC" \
    CXXFLAGS="-fPIC" \
    ./configure --cflags="-fPIC" \
        --config=Linux-clang \
        --prefix="${PREFIX}" \
        --no-sharedlibs --static --poquito --no-tests --no-samples \
        --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
        --include-path="${OUTPUT_INCLUDE}" --library-path="${OUTPUT_LIB}/${LIBRARY_NAME}"
    
    print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
    # CRITICAL: ARCHFLAGS must be set to empty string to override Poco's config file which sets it to -arch
    # The config file has: ARCHFLAGS ?= -arch $(POCO_HOST_OSARCH)
    # By setting ARCHFLAGS="" we override this and prevent -arch flags from being used on Linux
    CC=clang CXX=clang++ \
    ARCHFLAGS="" \
    CFLAGS="-fPIC" \
    CXXFLAGS="-fPIC" \
    make -j${JOBS}
    make install
fi

# Copy headers
cp -R "${PREFIX}/include/Poco"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true

# Copy all Poco libraries
cp "${PREFIX}/lib/libPocoCrypto.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libPocoFoundation.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libPocoJSON.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libPocoNet.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libPocoPDF.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libPocoXML.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libPocoUtil.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libPocoZip.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
