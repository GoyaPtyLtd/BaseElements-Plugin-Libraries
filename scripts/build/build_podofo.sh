#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="podofo"
# Select archive based on platform: Linux uses 0.9.8, macOS uses 1.0.2b
# NOTE: Ubuntu 22.04 cannot build PoDoFo versions past 0.9.8 due to CMake version limitations.
# Ubuntu 22.04 ships with CMake 3.22.1, but PoDoFo 1.0.2b+ requires CMake 3.23+.
# macOS uses 1.0.2b because it has CMake 3.23+ available via Homebrew.
if [[ $OS = 'Darwin' ]]; then
    ARCHIVE_NAME="podofo-macos.tar.gz"
else
    ARCHIVE_NAME="podofo-linux.tar.gz"
fi

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

# Check required libraries (bash 3 compatible - using arrays instead of associative arrays)
REQUIRED_LIB_NAMES=("freetype" "fontconfig" "libssl" "libcrypto" "libxml2" "libunistring" "libz" "libturbojpeg" "libpng16")
REQUIRED_LIB_PATHS=(
    "${OUTPUT_LIB}/freetype2/libfreetype.a"
    "${OUTPUT_LIB}/fontconfig/libfontconfig.a"
    "${OUTPUT_LIB}/openssl/libssl.a"
    "${OUTPUT_LIB}/openssl/libcrypto.a"
    "${OUTPUT_LIB}/libxml/libxml2.a"
    "${OUTPUT_LIB}/libunistring/libunistring.a"
    "${OUTPUT_LIB}/zlib/libz.a"
    "${OUTPUT_LIB}/libturbojpeg/libturbojpeg.a"
    "${OUTPUT_LIB}/libpng/libpng16.a"
)

# Check required headers
REQUIRED_HEADER_NAMES=("freetype2" "fontconfig" "openssl" "libxml" "libunistring" "zlib" "libturbojpeg" "libpng")
REQUIRED_HEADER_PATHS=(
    "${OUTPUT_INCLUDE}/freetype2"
    "${OUTPUT_INCLUDE}/fontconfig"
    "${OUTPUT_INCLUDE}/openssl"
    "${OUTPUT_INCLUDE}/libxml"
    "${OUTPUT_INCLUDE}/libunistring"
    "${OUTPUT_INCLUDE}/zlib"
    "${OUTPUT_INCLUDE}/libturbojpeg"
    "${OUTPUT_INCLUDE}/libpng"
)

# Verify libraries exist
i=0
for lib_name in "${REQUIRED_LIB_NAMES[@]}"; do
    lib_path="${REQUIRED_LIB_PATHS[$i]}"
    if [[ ! -f "$lib_path" ]]; then
        MISSING_DEPS+=("Library: $lib_name ($lib_path)")
    fi
    i=$((i + 1))
done

# Verify headers exist
i=0
for header_name in "${REQUIRED_HEADER_NAMES[@]}"; do
    header_path="${REQUIRED_HEADER_PATHS[$i]}"
    if [[ ! -d "$header_path" ]]; then
        MISSING_DEPS+=("Headers: $header_name ($header_path)")
    fi
    i=$((i + 1))
done

# Check xmllint executable (required for macOS)
if [[ $OS = 'Darwin' ]]; then
    XMLLINT_PATH="${OUTPUT_SRC}/libxml/_build/bin/xmllint"
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
 
    cd "${BUILD_DIR}"
    
    # Build include path flags to prioritize our libraries over system ones (especially Mono framework)
    # This ensures we use our built libjpeg/libpng instead of system versions
    INCLUDE_FLAGS="-I${OUTPUT_INCLUDE}/libturbojpeg -I${OUTPUT_INCLUDE}/libpng -I${OUTPUT_INCLUDE}/zlib"
    
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
         -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
		 -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT_LIB}/freetype2/libfreetype.a" -DFREETYPE_INCLUDE_DIRS="${OUTPUT_INCLUDE}/freetype2" \
         -DFontconfig_LIBRARY="${OUTPUT_LIB}/fontconfig/libfontconfig.a" -DFontconfig_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DOPENSSL_SSL_LIBRARY="${OUTPUT_LIB}/openssl/libssl.a" -DOPENSSL_CRYPTO_LIBRARY="${OUTPUT_LIB}/openssl/libcrypto.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT_INCLUDE}/openssl" \
         -DLIBXML2_LIBRARY="${OUTPUT_LIB}/libxml/libxml2.a" -DLIBXML2_INCLUDE_DIR="${OUTPUT_INCLUDE}/libxml" \
         -DLIBXML2_XMLLINT_EXECUTABLE="${OUTPUT_SRC}/libxml/_build/bin/xmllint" \
         -DZLIB_LIBRARY_RELEASE="${OUTPUT_LIB}/zlib/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib" \
         -DJPEG_LIBRARY_RELEASE="${OUTPUT_LIB}/libturbojpeg/libturbojpeg.a" -DJPEG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libturbojpeg" \
         -DPNG_LIBRARY="${OUTPUT_LIB}/libpng/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libpng" \
         -DCMAKE_IGNORE_PATH="/Library/Frameworks/Mono.framework;/usr/local/lib" \
         -DCMAKE_CXX_STANDARD=17 \
         -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=13.3 -stdlib=libc++ ${INCLUDE_FLAGS}" \
         -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=13.3 -stdlib=libc++ ${INCLUDE_FLAGS}" ..
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
         -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT_LIB}/freetype2/libfreetype.a" -DFREETYPE_INCLUDE_DIR="${OUTPUT_INCLUDE}/freetype2" \
         -DWANT_FONTCONFIG:BOOL=TRUE \
         -DFONTCONFIG_LIBRARIES="${OUTPUT_LIB}/fontconfig/libfontconfig.a" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DLIBCRYPTO_LIBRARY="${OUTPUT_LIB}/openssl/libcrypto.a" -DLIBCRYPTO_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DOPENSSL_LIBRARIES="${OUTPUT_LIB}/openssl/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DUNISTRING_LIBRARY="${OUTPUT_LIB}/libunistring/libunistring.a" -DUNISTRING_INCLUDE_DIR="${OUTPUT_INCLUDE}/libunistring" \
         -DZLIB_LIBRARY_RELEASE="${OUTPUT_LIB}/zlib/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib" \
         -DLIBJPEG_LIBRARY_RELEASE="${OUTPUT_LIB}/libturbojpeg/libturbojpeg.a" -DLIBJPEG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libturbojpeg" \
         -DPNG_LIBRARY="${OUTPUT_LIB}/libpng/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libpng" \
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
    cp "${PREFIX}/lib/lib${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
else
    cp "${PREFIX}/lib64/lib${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
fi

print_success "Build complete for ${LIBRARY_NAME}"
