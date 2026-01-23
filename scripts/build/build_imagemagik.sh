#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="ImageMagick-7"
ARCHIVE_NAME="ImageMagick.tar.gz"

print_header "Starting BE Library Build : ${LIBRARY_NAME}"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
SCRIPT_DIR="$(dirname "$0")"
MISSING_DEPS=()

if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
	print_info "Missing dependency : zlib..."
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
if [[ ! -f "${OUTPUT_LIB}/libheif/libheif.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libheif" ]]; then
	print_info "Missing dependencies : libheif..."
	print_info "Start build : libheif..."
	"${SCRIPT_DIR}/build_libheif.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/freetype2/libfreetype.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/freetype2" ]]; then
	print_info "Missing dependencies : freetype2..."
	print_info "Start build : freetype2..."
	"${SCRIPT_DIR}/build_freetype.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/fontconfig/libfontconfig.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/fontconfig" ]]; then
	print_info "Missing dependencies : fontconfig..."
	print_info "Start build : fontconfig..."
	"${SCRIPT_DIR}/build_fontconfig.sh"
fi

# libopenjp2 is required only on macOS
if [[ $OS = 'Darwin' ]]; then
	if [[ ! -f "${OUTPUT_LIB}/libopenjp2/libopenjp2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libopenjp2" ]]; then
		print_info "Missing dependencies : libopenjp2..."
		print_info "Start build : libopenjp2..."
		"${SCRIPT_DIR}/build_libopenjp2.sh"
	fi
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
if [[ ! -f "${OUTPUT_LIB}/libheif/libheif.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libheif" ]]; then
    MISSING_DEPS+=("libheif")
fi
if [[ ! -f "${OUTPUT_LIB}/freetype2/libfreetype.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/freetype2" ]]; then
    MISSING_DEPS+=("freetype2")
fi
if [[ ! -f "${OUTPUT_LIB}/fontconfig/libfontconfig.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/fontconfig" ]]; then
    MISSING_DEPS+=("fontconfig")
fi
# libopenjp2 headers are required only on macOS
if [[ $OS = 'Darwin' ]]; then
	if [[ ! -f "${OUTPUT_LIB}/libopenjp2/libopenjp2.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libopenjp2" ]]; then
  	  MISSING_DEPS+=("libopenjp2")
	fi
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

# Set up PKG_CONFIG_PATH for dependencies
PKG_CONFIG_BASE="${OUTPUT_SRC}/zlib/_build/lib/pkgconfig"
PKG_CONFIG_BASE="${PKG_CONFIG_BASE}:${OUTPUT_SRC}/libpng/_build/lib/pkgconfig"
PKG_CONFIG_BASE="${PKG_CONFIG_BASE}:${OUTPUT_SRC}/libde265/_build/lib/pkgconfig"
PKG_CONFIG_BASE="${PKG_CONFIG_BASE}:${OUTPUT_SRC}/libheif/_build/lib/pkgconfig"
PKG_CONFIG_BASE="${PKG_CONFIG_BASE}:${OUTPUT_SRC}/freetype2/_build/lib/pkgconfig"
PKG_CONFIG_BASE="${PKG_CONFIG_BASE}:${OUTPUT_SRC}/fontconfig/_build/lib/pkgconfig"

export PKG_CONFIG_PATH

# Configure and build
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build (separate arm64 and x86_64 builds, then lipo)
    
    # Build arm64
    BUILD_DIR_arm64="${BUILD_DIR}_arm64"
    mkdir -p "${BUILD_DIR_arm64}"
    PREFIX_arm64="${BUILD_DIR_arm64}"
 
    PKG_CONFIG_PATH="${PKG_CONFIG_BASE}:${OUTPUT_SRC}/libopenjp2/_build"
	PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OUTPUT_SRC}/libturbojpeg/_build_arm64/lib/pkgconfig"
    export PKG_CONFIG_PATH
 
    print_info "Configuring for macOS (arm64)..."
 
    CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
    CXXFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
    ./configure --disable-shared --disable-docs --disable-dependency-tracking \
        --with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-tiff=no --with-lcms=no \
		--with-openjp2=yes \
        --without-utilities --without-xml --without-lzma --without-x --with-quantum-depth=16 \
        --enable-zero-configuration --enable-hdri --without-bzlib --disable-openmp --disable-assert \
        --without-lcms --without-lqr --without-djvu --without-openexr --without-jbig \
        --host="arm64-apple-darwin" \
        --prefix="${PREFIX_arm64}"
    
    print_info "Building ${LIBRARY_NAME} for arm64 (${JOBS} parallel jobs)..."
    make -j${JOBS}
    make install
    make -s distclean
    
    # Build x86_64
    BUILD_DIR_x86_64="${BUILD_DIR}_x86_64"
    mkdir -p "${BUILD_DIR_x86_64}"
    PREFIX_x86_64="${BUILD_DIR_x86_64}"

    PKG_CONFIG_PATH="${PKG_CONFIG_BASE}:${OUTPUT_SRC}/libopenjp2/_build"
	PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OUTPUT_SRC}/libturbojpeg/_build_x86_64/lib/pkgconfig"
    export PKG_CONFIG_PATH

    print_info "Configuring for macOS (x86_64)..."
    
    CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
    CXXFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --disable-docs --disable-dependency-tracking \
        --with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-tiff=no --with-lcms=no \
		--with-openjp2=yes \
        --without-utilities --without-xml --without-lzma --without-x --with-quantum-depth=16 \
        --enable-zero-configuration --enable-hdri --without-bzlib --disable-openmp --disable-assert \
        --without-lcms --without-lqr --without-djvu --without-openexr --without-jbig \
        --host="x86_64-apple-darwin" \
        --prefix="${PREFIX_x86_64}"
    
    print_info "Building ${LIBRARY_NAME} for x86_64 (${JOBS} parallel jobs)..."
    make -j${JOBS}
    make install
    make -s distclean
    
    # Create universal binaries
    print_info "Creating universal binaries..."
    mkdir -p "${PREFIX}/lib"
    mkdir -p "${PREFIX}/include/ImageMagick-7"
    cp -R "${PREFIX_x86_64}/include/ImageMagick-7"/* "${PREFIX}/include/ImageMagick-7/"

    lipo -create "${PREFIX_x86_64}/lib/libMagick++-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagick++-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagick++-7.Q16HDRI.a"
    lipo -create "${PREFIX_x86_64}/lib/libMagickCore-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagickCore-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagickCore-7.Q16HDRI.a"
    lipo -create "${PREFIX_x86_64}/lib/libMagickWand-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagickWand-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagickWand-7.Q16HDRI.a"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."

	PKG_CONFIG_PATH="${PKG_CONFIG_BASE}:${OUTPUT_SRC}/libturbojpeg/_build/lib/pkgconfig"
    export PKG_CONFIG_PATH

    CC=clang CXX=clang++ \
    CFLAGS="-fPIC" \
    ./configure --disable-shared --disable-docs --disable-dependency-tracking \
        --with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-tiff=no --with-lcms=no \
        --without-utilities --without-xml --without-lzma --without-x --with-quantum-depth=16 \
        --enable-zero-configuration --enable-hdri --without-bzlib --disable-openmp --disable-assert \
        --without-lcms --without-lqr --without-djvu --without-openexr --without-jbig \
        --prefix="${PREFIX}"
    
    print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
    make -j${JOBS}
    make install
fi

# Copy headers and libraries
cp -R "${PREFIX}/include/ImageMagick-7"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true

cp "${PREFIX}/lib/libMagick++-7.Q16HDRI.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libMagickCore-7.Q16HDRI.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libMagickWand-7.Q16HDRI.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
