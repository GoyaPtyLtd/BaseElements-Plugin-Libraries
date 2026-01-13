#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="podofo"
ARCHIVE_NAME="podofo.tar.gz"

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

# Check dependencies before configuring
print_info "Checking dependencies for ${LIBRARY_NAME}..."
SCRIPT_DIR="$(dirname "$0")"
MISSING_DEPS=()

if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
	print_info "Missing dependency : zlib..."
	print_info "Start build : zlib..."
	"${SCRIPT_DIR}/build_zlib.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/freetype2/libfreetype.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/freetype2" ]]; then
	print_info "Missing dependency : freetype2..."
	print_info "Start build : freetype2..."
	"${SCRIPT_DIR}/build_freetype.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/fontconfig/libfontconfig.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/fontconfig" ]]; then
	print_info "Missing dependency : fontconfig..."
	print_info "Start build : fontconfig..."
	"${SCRIPT_DIR}/build_fontconfig.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/libxml/libxml2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libxml" ]]; then
	print_info "Missing dependency : libxml..."
	print_info "Start build : libxml..."
	"${SCRIPT_DIR}/build_libxml.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/libunistring/libunistring.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libunistring" ]]; then
	print_info "Missing dependency : libunistring..."
	print_info "Start build : libunistring..."
	"${SCRIPT_DIR}/build_libunistring.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/libturbojpeg/libturbojpeg.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libturbojpeg" ]]; then
	print_info "Missing dependency : libturbojpeg..."
	print_info "Start build : libturbojpeg..."
	"${SCRIPT_DIR}/build_libturbojpeg.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/libpng/libpng16.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libpng" ]]; then
	print_info "Missing dependency : libpng..."
	print_info "Start build : libpng..."
	"${SCRIPT_DIR}/build_libpng.sh"
fi

if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
    MISSING_DEPS+=("zlib")
fi
if [[ ! -f "${OUTPUT_LIB}/freetype2/libfreetype.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/freetype2" ]]; then
    MISSING_DEPS+=("freetype2")
fi
if [[ ! -f "${OUTPUT_LIB}/fontconfig/libfontconfig.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/fontconfig" ]]; then
    MISSING_DEPS+=("fontconfig")
fi
if [[ ! -f "${OUTPUT_LIB}/openssl/libssl.a" ]] || [[ ! -f "${OUTPUT_LIB}/openssl/libcrypto.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/openssl" ]]; then
    MISSING_DEPS+=("openssl")
fi
if [[ ! -f "${OUTPUT_LIB}/libxml/libxml2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libxml" ]]; then
    MISSING_DEPS+=("libxml")
fi
if [[ ! -f "${OUTPUT_LIB}/libunistring/libunistring.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libunistring" ]]; then
    MISSING_DEPS+=("libunistring")
fi
if [[ ! -f "${OUTPUT_LIB}/libturbojpeg/libturbojpeg.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libturbojpeg" ]]; then
    MISSING_DEPS+=("libturbojpeg")
fi
if [[ ! -f "${OUTPUT_LIB}/libpng/libpng16.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libpng" ]]; then
    MISSING_DEPS+=("libpng")
fi

# Report missing dependencies
if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    print_error "ERROR: Missing dependencies for ${LIBRARY_NAME}:"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - ${dep}"
    done
    exit 1
fi

# Check xmllint executable (required for macOS)
if [[ $OS = 'Darwin' ]]; then
    XMLLINT_PATH="${OUTPUT_SRC}/libxml/_build/bin/xmllint"
    if [[ ! -f "$XMLLINT_PATH" ]]; then
        MISSING_DEPS+=("Executable: xmllint ($XMLLINT_PATH)")
    fi
fi

print_success "All dependencies found for ${LIBRARY_NAME}"

# Configure with cmake
cd "${BUILD_DIR}"

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build (arm64 + x86_64)
    print_info "Configuring ${LIBRARY_NAME} for macOS (universal: arm64 + x86_64)..."
     
    # Build include path flags to prioritize our libraries over system ones (especially Mono framework)
    # This ensures we use our built libjpeg/libpng instead of system versions
    INCLUDE_FLAGS="-I${OUTPUT_INCLUDE}/libturbojpeg -I${OUTPUT_INCLUDE}/libpng -I${OUTPUT_INCLUDE}/zlib -I${OUTPUT_INCLUDE}"
    
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
         -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
		 -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT_LIB}/freetype2/libfreetype.a" -DFREETYPE_INCLUDE_DIRS="${OUTPUT_INCLUDE}/freetype2"  \
         -DFontconfig_LIBRARY="${OUTPUT_LIB}/fontconfig/libfontconfig.a" -DFontconfig_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DOPENSSL_LIBRARIES="${OUTPUT_LIB}/openssl/libssl.a" -DOPENSSL_SSL_LIBRARY="${OUTPUT_LIB}/openssl/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT_INCLUDE}/openssl"  -DOPENSSL_INCLUDE_DIR="${OUTPUT_INCLUDE}"  \
         -DOPENSSL_CRYPTO_LIBRARY="${OUTPUT_LIB}/openssl/libcrypto.a" \
         -DLIBXML2_LIBRARY="${OUTPUT_LIB}/libxml/libxml2.a" -DLIBXML2_INCLUDE_DIR="${OUTPUT_INCLUDE}/libxml"  -DLIBXML2_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DLIBXML2_XMLLINT_EXECUTABLE="${OUTPUT_SRC}/libxml/_build/bin/xmllint" \
         -DZLIB_LIBRARY_RELEASE="${OUTPUT_LIB}/zlib/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib" \
         -DJPEG_LIBRARY_RELEASE="${OUTPUT_LIB}/libturbojpeg/libturbojpeg.a" -DJPEG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libturbojpeg" \
         -DPNG_LIBRARY="${OUTPUT_LIB}/libpng/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libpng" \
         -DCMAKE_IGNORE_PREFIX_PATH="/Library/Frameworks;/usr/local;/opt/homebrew" \
         -DCMAKE_CXX_STANDARD=11 \
         -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=13.3 -stdlib=libc++" \
         -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=13.3 -stdlib=libc++" ..
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring ${LIBRARY_NAME} for Linux..."
    CC=clang CXX=clang++ \
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
		 -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT_LIB}/freetype2/libfreetype.a" -DFREETYPE_INCLUDE_DIRS="${OUTPUT_INCLUDE}/freetype2"  \
         -DFontconfig_LIBRARY="${OUTPUT_LIB}/fontconfig/libfontconfig.a" -DFontconfig_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DOPENSSL_LIBRARIES="${OUTPUT_LIB}/openssl/libssl.a" -DOPENSSL_SSL_LIBRARY="${OUTPUT_LIB}/openssl/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT_INCLUDE}/openssl"  -DOPENSSL_INCLUDE_DIR="${OUTPUT_INCLUDE}"  \
         -DOPENSSL_CRYPTO_LIBRARY="${OUTPUT_LIB}/openssl/libcrypto.a" \
         -DLIBXML2_LIBRARY="${OUTPUT_LIB}/libxml/libxml2.a" -DLIBXML2_INCLUDE_DIR="${OUTPUT_INCLUDE}/libxml"  -DLIBXML2_INCLUDE_DIR="${OUTPUT_INCLUDE}" \
         -DLIBXML2_XMLLINT_EXECUTABLE="${OUTPUT_SRC}/libxml/_build/bin/xmllint" \
         -DZLIB_LIBRARY_RELEASE="${OUTPUT_LIB}/zlib/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib" \
         -DJPEG_LIBRARY_RELEASE="${OUTPUT_LIB}/libturbojpeg/libturbojpeg.a" -DJPEG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libturbojpeg" \
         -DPNG_LIBRARY="${OUTPUT_LIB}/libpng/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT_INCLUDE}/libpng" \
         -DCMAKE_IGNORE_PREFIX_PATH="/usr/lib;/opt/homebrew;/lib/aarch64-linux-gnu;/lib/x86_64-linux-gnu;/usr/lib/x86_64-linux-gnu/" \
         -DCMAKE_CXX_FLAGS="-fPIC" ..
fi

# Build
print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make -j${JOBS}
make install

# Copy headers and libraries
cp -R "${PREFIX}/include/podofo"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true

cp "${PREFIX}/lib/libpodofo.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libpodofo_private.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libpodofo_3rdparty.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
