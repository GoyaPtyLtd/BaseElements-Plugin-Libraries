#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="podofo"
ARCHIVE_NAME="podofo.tar.gz"

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

# Check dependencies before configuring
print_info "Checking dependencies for ${LIBRARY_NAME}..."
MISSING_DEPS=()

# Check required libraries
declare -A REQUIRED_LIBS=(
    ["freetype"]="${OUTPUT_LIB}/freetype/libfreetype.a"
    ["fontconfig"]="${OUTPUT_LIB}/fontconfig/fontconfig.a"
    ["libssl"]="${OUTPUT_LIB}/curl/libssl.a"
    ["libcrypto"]="${OUTPUT_LIB}/curl/libcrypto.a"
    ["libxml2"]="${OUTPUT_LIB}/xml/libxml2.a"
    ["libunistring"]="${OUTPUT_LIB}/font/libunistring.a"
    ["libz"]="${OUTPUT_LIB}/curl/libz.a"
    ["libturbojpeg"]="${OUTPUT_LIB}/image/libturbojpeg.a"
    ["libpng16"]="${OUTPUT_LIB}/image/libpng16.a"
)

# Check required headers
declare -A REQUIRED_HEADERS=(
    ["freetype2"]="${OUTPUT_INCLUDE}/freetype2"
    ["fontconfig"]="${OUTPUT_INCLUDE}/fontconfig"
    ["openssl"]="${OUTPUT_INCLUDE}/openssl"
    ["libxml"]="${OUTPUT_INCLUDE}/libxml"
    ["libunistring"]="${OUTPUT_INCLUDE}/libunistring"
    ["zlib"]="${OUTPUT_INCLUDE}/zlib"
    ["libturbojpeg"]="${OUTPUT_INCLUDE}/libturbojpeg"
    ["libpng"]="${OUTPUT_INCLUDE}/libpng"
)

# Verify libraries exist
for lib_name in "${!REQUIRED_LIBS[@]}"; do
    lib_path="${REQUIRED_LIBS[$lib_name]}"
    if [[ ! -f "$lib_path" ]]; then
        MISSING_DEPS+=("Library: $lib_name ($lib_path)")
    fi
done

# Verify headers exist
for header_name in "${!REQUIRED_HEADERS[@]}"; do
    header_path="${REQUIRED_HEADERS[$header_name]}"
    if [[ ! -d "$header_path" ]]; then
        MISSING_DEPS+=("Headers: $header_name ($header_path)")
    fi
done

# Check xmllint executable (required for macOS)
if [[ $OS = 'Darwin' ]]; then
    XMLLINT_PATH="${OUTPUT_SRC}/xml/_build/bin/xmllint"
    if [[ ! -f "$XMLLINT_PATH" ]]; then
        MISSING_DEPS+=("Executable: xmllint ($XMLLINT_PATH)")
    fi
fi

# Report missing dependencies
if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    print_error "ERROR: Missing dependencies for ${LIBRARY_NAME}:"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - ${dep}"
    done
    echo ""
    echo "Please build dependencies first:"
    echo "  curl (zlib, openssl)"
    echo "  font (libunistring)"
    echo "  xml (libxml2)"
    echo "  image (libturbojpeg, libpng)"
    echo "  freetype, fontconfig"
    exit 1
fi

print_success "All dependencies found for ${LIBRARY_NAME}"

# Configure with cmake
interactive_prompt \
    "Ready to configure ${LIBRARY_NAME} with cmake" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}" \
    "Dependencies will be found from: ${OUTPUT_INCLUDE} and ${OUTPUT_LIB}"

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build (arm64 + x86_64)
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
         -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE -DPODOFO_BUILD_SHARED:BOOL=FALSE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT_LIB}/freetype/libfreetype.a" -DFREETYPE_INCLUDE_DIR="${OUTPUT_INCLUDE}/freetype2" \
         -DWANT_FONTCONFIG:BOOL=TRUE \
         -DFONTCONFIG_LIBRARIES="${OUTPUT_LIB}/fontconfig/fontconfig.a" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DOPENSSL_LIBRARIES="${OUTPUT_LIB}/curl/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DLIBCRYPTO_LIBRARIES="${OUTPUT_LIB}/curl/libcrypto.a" -DLIBCRYPTO_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DLIBXML2_LIBRARY="${OUTPUT_LIB}/xml/libxml2.a" -DLIBXML2_INCLUDE_DIR="${OUTPUT_INCLUDE}/libxml" \
         -DLIBXML2_XMLLINT_EXECUTABLE="${OUTPUT_SRC}/xml/_build/bin/xmllint" \
         -DUNISTRING_LIBRARY="${OUTPUT_LIB}/font/libunistring.a" -DUNISTRING_INCLUDE_DIR="${OUTPUT_INCLUDE}/libunistring" \
         -DZLIB_LIBRARY_RELEASE="${OUTPUT_LIB}/curl/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib" \
         -DLIBJPEG_LIBRARY_RELEASE="${OUTPUT_LIB}/image/libturbojpeg.a" -DLIBJPEG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libturbojpeg" \
         -DPNG_LIBRARY="${OUTPUT_LIB}/image/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libpng" \
         -DCMAKE_CXX_STANDARD=11 \
         -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" \
         -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" .
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
         -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT_LIB}/freetype/libfreetype.a" -DFREETYPE_INCLUDE_DIR="${OUTPUT_INCLUDE}/freetype2" \
         -DWANT_FONTCONFIG:BOOL=TRUE \
         -DFONTCONFIG_LIBRARIES="${OUTPUT_LIB}/fontconfig/fontconfig.a" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DLIBCRYPTO_LIBRARY="${OUTPUT_LIB}/curl/libcrypto.a" -DLIBCRYPTO_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DOPENSSL_LIBRARIES="${OUTPUT_LIB}/curl/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DUNISTRING_LIBRARY="${OUTPUT_LIB}/font/libunistring.a" -DUNISTRING_INCLUDE_DIR="${OUTPUT_INCLUDE}/libunistring" \
         -DZLIB_LIBRARY_RELEASE="${OUTPUT_LIB}/curl/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib" \
         -DLIBJPEG_LIBRARY_RELEASE="${OUTPUT_LIB}/image/libturbojpeg.a" -DLIBJPEG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libturbojpeg" \
         -DPNG_LIBRARY="${OUTPUT_LIB}/image/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libpng" \
         -DWANT_LIB64:BOOL=TRUE \
         -DCMAKE_CXX_FLAGS="-fPIC" .
fi

# Build
interactive_prompt \
    "Ready to build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Jobs: ${JOBS}" \
    "Build prefix: ${PREFIX}"

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make -j${JOBS}
make install

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Library: ${OUTPUT_LIB}/${LIBRARY_NAME}/lib${LIBRARY_NAME}.a"

cp -R "${PREFIX}/include/podofo"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true

# Copy library (different paths for macOS vs Linux)
if [[ $OS = 'Darwin' ]]; then
    cp "${PREFIX}/lib/lib${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/" 2>/dev/null || true
else
    cp "${PREFIX}/lib64/lib${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/" 2>/dev/null || true
fi

print_success "Build complete for ${LIBRARY_NAME}"
