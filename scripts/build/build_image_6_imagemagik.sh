#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="ImageMagick-7"
ARCHIVE_NAME="ImageMagick.tar.gz"

print_header "Starting ${LIBRARY_NAME} Build"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
MISSING_DEPS=()

# Check required libraries
REQUIRED_LIBS=(
    "zlib:libz.a"
    "libpng:libpng16.a"
    "libde265:libde265.a"
    "libheif:libheif.a"
    "libturbojpeg:libjpeg.a"
    "freetype2:libfreetype.a"
    "fontconfig:libfontconfig.a"
)

# libopenjp2 is required only on macOS
if [[ $OS = 'Darwin' ]]; then
    REQUIRED_LIBS+=("libopenjp2:libopenjp2.a")
fi

for lib_entry in "${REQUIRED_LIBS[@]}"; do
    IFS=':' read -r lib_name lib_file <<< "$lib_entry"
    if [[ ! -f "${OUTPUT_LIB}/${lib_name}/${lib_file}" ]]; then
        MISSING_DEPS+=("Library: ${lib_name} (${OUTPUT_LIB}/${lib_name}/${lib_file})")
    fi
done

# Check required headers
REQUIRED_HEADERS=("zlib" "libpng" "libde265" "libheif" "libturbojpeg" "freetype2" "fontconfig")

# libopenjp2 headers are required only on macOS
if [[ $OS = 'Darwin' ]]; then
    REQUIRED_HEADERS+=("libopenjp2")
fi

for header_dir in "${REQUIRED_HEADERS[@]}"; do
    if [[ ! -d "${OUTPUT_INCLUDE}/${header_dir}" ]]; then
        MISSING_DEPS+=("Headers: ${header_dir} (${OUTPUT_INCLUDE}/${header_dir})")
    fi
done

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
    echo "  image_3_libpng (libpng)"
    echo "  image_4_libheif (libheif)"
    if [[ $OS = 'Darwin' ]]; then
        echo "  image_5_libopenjp2 (libopenjp2) - macOS only"
    fi
    echo "  font_3_freetype (freetype2)"
    echo "  font_4_fontconfig (fontconfig)"
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

# Set up PKG_CONFIG_PATH for dependencies
PKG_CONFIG_PATH="${OUTPUT_SRC}/zlib/_build/lib/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OUTPUT_SRC}/libpng/_build/lib/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OUTPUT_SRC}/libde265/_build/lib/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OUTPUT_SRC}/libheif/_build/lib/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OUTPUT_SRC}/fontconfig/_build/lib/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OUTPUT_SRC}/freetype/_build/lib/pkgconfig"
# libopenjp2 is only needed on macOS
if [[ $OS = 'Darwin' ]]; then
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OUTPUT_SRC}/libopenjp2/_build/lib/pkgconfig"
fi
PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${OUTPUT_SRC}/libturbojpeg/_build/lib/pkgconfig"
export PKG_CONFIG_PATH

# Configure and build
interactive_prompt \
    "Ready to configure and build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}" \
    "Dependencies will be found from: ${OUTPUT_INCLUDE} and ${OUTPUT_LIB}"

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build (separate arm64 and x86_64 builds, then lipo)
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    
    # Build arm64
    BUILD_DIR_arm64="${BUILD_DIR}_arm64"
    mkdir -p "${BUILD_DIR_arm64}"
    PREFIX_arm64="${BUILD_DIR_arm64}"
    
    CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
    CXXFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
    CPPFLAGS="-I${OUTPUT_INCLUDE}/libturbojpeg" LDFLAGS="-L${OUTPUT_LIB}" \
    ./configure --disable-shared --disable-docs --disable-dependency-tracking \
        --with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-openjp2=yes \
        --without-utilities --without-xml --without-lzma --without-x --with-quantum-depth=16 \
        --enable-zero-configuration --enable-hdri --without-bzlib --disable-openmp --disable-assert \
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
    
    CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
    CXXFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
    CPPFLAGS="-I${OUTPUT_INCLUDE}/libturbojpeg" LDFLAGS="-L${OUTPUT_LIB}" \
    ./configure --disable-shared --disable-docs --disable-dependency-tracking \
        --with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes --with-openjp2=yes \
        --without-utilities --without-xml --without-lzma --without-x --with-quantum-depth=16 \
        --enable-zero-configuration --enable-hdri --without-bzlib --disable-openmp --disable-assert \
        --host="x86_64-apple-darwin" \
        --prefix="${PREFIX_x86_64}"
    
    print_info "Building ${LIBRARY_NAME} for x86_64 (${JOBS} parallel jobs)..."
    make -j${JOBS}
    make install
    make -s distclean
    
    # Create universal binaries
    mkdir -p "${PREFIX}/lib"
    print_info "Creating universal binaries..."
    lipo -create "${PREFIX_x86_64}/lib/libMagick++-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagick++-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagick++-7.Q16HDRI.a"
    lipo -create "${PREFIX_x86_64}/lib/libMagickCore-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagickCore-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagickCore-7.Q16HDRI.a"
    lipo -create "${PREFIX_x86_64}/lib/libMagickWand-7.Q16HDRI.a" "${PREFIX_arm64}/lib/libMagickWand-7.Q16HDRI.a" -output "${PREFIX}/lib/libMagickWand-7.Q16HDRI.a"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    CFLAGS="-fPIC" \
    ./configure --disable-shared --disable-docs --disable-dependency-tracking \
        --with-heic=yes --with-freetype=yes --with-fontconfig=yes --with-png=yes --with-jpeg=yes \
        --without-utilities --without-xml --without-lzma --without-x --with-quantum-depth=16 \
        --enable-zero-configuration --enable-hdri --without-bzlib --disable-openmp --disable-assert \
        --without-lcms --without-lqr --without-djvu --without-openexr --without-jbig --without-tiff  --without-openjp2 \
        --prefix="${PREFIX}"
    
    print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
    make -j${JOBS}
    make install
fi

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Libraries: ${OUTPUT_LIB}/${LIBRARY_NAME}/libMagick*.a"

if [[ $OS = 'Darwin' ]]; then
    cp -R "${PREFIX_x86_64}/include/ImageMagick-7"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
else
    cp -R "${PREFIX}/include/ImageMagick-7"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
fi

cp "${PREFIX}/lib/libMagick++-7.Q16HDRI.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libMagickCore-7.Q16HDRI.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
cp "${PREFIX}/lib/libMagickWand-7.Q16HDRI.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
