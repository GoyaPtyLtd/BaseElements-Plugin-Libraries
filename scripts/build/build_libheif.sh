#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="libheif"
ARCHIVE_NAME="libheif.tar.gz"

print_header "Starting BE Library Build : ${LIBRARY_NAME}"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
MISSING_DEPS=()

# Check required libraries
if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
	print_info "Missing dependencies : zlib..."
	print_info "Start build : zlib..."
	"${SCRIPT_DIR}/build_zlib.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/libde265/libde265.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libde265" ]]; then
	print_info "Missing dependencies : libde265..."
	print_info "Start build : libde265..."
	"${SCRIPT_DIR}/build_libde265.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/libturbojpeg/libjpeg.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libturbojpeg" ]]; then
	print_info "Missing dependencies : libturbojpeg..."
	print_info "Start build : libturbojpeg..."
	"${SCRIPT_DIR}/build_libturbojpeg.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/libpng/libpng16.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libpng" ]]; then
	print_info "Missing dependencies : libpng..."
	print_info "Start build : libpng..."
	"${SCRIPT_DIR}/build_libpng.sh"
fi

if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
    MISSING_DEPS+=("zlib")
fi
if [[ ! -f "${OUTPUT_LIB}/libde265/libde265.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libde265" ]]; then
    MISSING_DEPS+=("libde265")
fi
if [[ ! -f "${OUTPUT_LIB}/libturbojpeg/libjpeg.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libturbojpeg" ]]; then
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
mkdir -p "${BUILD_DIR}"
PREFIX="${BUILD_DIR}"

# Configure and build
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    export MACOSX_DEPLOYMENT_TARGET=10.15
    
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -Wno-deprecated-declarations -Wno-pointer-sign -Wno-unused-const-variable -Wno-unused-function -Wno-unused-variable" \
    CPPFLAGS+="-Wno-deprecated-declarations -Wno-pointer-sign -Wno-unused-const-variable -Wno-unused-function -Wno-unused-variable" \
    cmake -G "Unix Makefiles" --preset=release-noplugins -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=RELEASE \
		-DCMAKE_IGNORE_PREFIX_PATH="/usr/local/;/opt/homebrew/" \
        -DBUILD_SHARED_LIBS:BOOL=OFF -DWITH_REDUCED_VISIBILITY=OFF -DWITH_UNCOMPRESSED_CODEC=OFF -DWITH_EXAMPLES=OFF \
		-DWITH_LIBDE265=ON -DWITH_JPEG_DECODER=ON -DWITH_JPEG_ENCODER=ON \
        -DWITH_OpenJPEG_DECODER=OFF -DWITH_OpenJPEG_ENCODER=OFF \
        -DWITH_TIFF=OFF \
        -DWITH_AOM_DECODER:BOOL=OFF -DWITH_AOM_ENCODER:BOOL=OFF \
        -DWITH_X265:BOOL=OFF -DWITH_LIBSHARPYUV:BOOL=OFF \
        -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib/" -DZLIB_LIBRARY="${OUTPUT_LIB}/zlib/libz.a" \
        -DLIBDE265_INCLUDE_DIR="${OUTPUT_INCLUDE}" -DLIBDE265_LIBRARY="${OUTPUT_LIB}/libde265/libde265.a" \
        -DJPEG_INCLUDE_DIRS="${OUTPUT_INCLUDE}/libturbojpeg/" -DJPEG_LIBRARY="${OUTPUT_LIB}/libturbojpeg/libjpeg.a" \
        -DPNG_INCLUDE_DIRS="${OUTPUT_INCLUDE}/libpng/" -DPNG_LIBRARY="${OUTPUT_LIB}/libpng/libpng16.a" ./
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ CFLAGS="-fPIC" \
    cmake -G "Unix Makefiles" --preset=release-noplugins -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=RELEASE \
		-DCMAKE_IGNORE_PREFIX_PATH="/usr/local;/opt/homebrew;/lib/x86_64-linux-gnu;/usr/lib/x86_64-linux-gnu" \
        -DBUILD_SHARED_LIBS:BOOL=OFF -DWITH_REDUCED_VISIBILITY=OFF -DWITH_UNCOMPRESSED_CODEC=OFF -DWITH_EXAMPLES=OFF \
		-DWITH_LIBDE265=ON -DWITH_JPEG_DECODER=ON -DWITH_JPEG_ENCODER=ON \
        -DWITH_OpenJPEG_DECODER=OFF -DWITH_OpenJPEG_ENCODER=OFF \
        -DWITH_TIFF=OFF  -DWITH_TIFF:BOOL=OFF \
        -DWITH_AOM_DECODER:BOOL=OFF -DWITH_AOM_ENCODER:BOOL=OFF \
        -DWITH_X265:BOOL=OFF -DWITH_LIBSHARPYUV:BOOL=OFF \
        -DZLIB_INCLUDE_DIR="${OUTPUT_INCLUDE}/zlib/" -DZLIB_LIBRARY="${OUTPUT_LIB}/zlib/libz.a" \
        -DLIBDE265_INCLUDE_DIR="${OUTPUT_INCLUDE}" -DLIBDE265_LIBRARY="${OUTPUT_LIB}/libde265/libde265.a" \
        -DJPEG_INCLUDE_DIRS="${OUTPUT_INCLUDE}/libturbojpeg/" -DJPEG_LIBRARY="${OUTPUT_LIB}/libturbojpeg/libjpeg.a" \
        -DPNG_INCLUDE_DIRS="${OUTPUT_INCLUDE}/libpng/" -DPNG_LIBRARY="${OUTPUT_LIB}/libpng/libpng16.a" ./
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make -j${JOBS}
make install

# Copy headers and libraries
cp -R "${PREFIX}/include/${LIBRARY_NAME}"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
