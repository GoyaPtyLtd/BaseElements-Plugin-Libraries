#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="fontconfig"
ARCHIVE_NAME="fontconfig.tar.gz"

print_header "Starting BE Library Build : ${LIBRARY_NAME}"

# Check dependencies before building
print_info "Checking dependencies for ${LIBRARY_NAME}..."
SCRIPT_DIR="$(dirname "$0")"
MISSING_DEPS=()

if [[ ! -f "${OUTPUT_LIB}/libexpat/libexpat.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libexpat" ]]; then
	print_info "Missing dependency : libexpat..."
	print_info "Start build : libexpat..."
	"${SCRIPT_DIR}/build_libexpat.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/freetype2/libfreetype.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/freetype2" ]]; then
	print_info "Missing dependency : freetype..."
	print_info "Start build : freetype2..."
	"${SCRIPT_DIR}/build_freetype.sh"
fi
if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
	print_info "Missing dependency : zlib..."
	print_info "Start build : zlib..."
	"${SCRIPT_DIR}/build_zlib.sh"
fi

if [[ ! -f "${OUTPUT_LIB}/libexpat/libexpat.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/libexpat" ]]; then
    MISSING_DEPS+=("libexpat")
fi
if [[ ! -f "${OUTPUT_LIB}/freetype2/libfreetype.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/freetype2" ]]; then
    MISSING_DEPS+=("freetype")
fi
if [[ ! -f "${OUTPUT_LIB}/zlib/libz.a" ]] || [[ ! -d "${OUTPUT_INCLUDE}/zlib" ]]; then
    MISSING_DEPS+=("zlib")
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

# Set up dependency paths
LIBEXPAT_PREFIX="${OUTPUT_SRC}/libexpat/_build"

# Configure and build
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
    CPPFLAGS+="-Wno-deprecated-declarations -Wno-pointer-sign" \
    LDFLAGS="-L${OUTPUT_LIB}" \
    FREETYPE_CFLAGS="-I${OUTPUT_INCLUDE}/freetype2" FREETYPE_LIBS="-L${OUTPUT_LIB}/freetype2 -lfreetype" \
    ./configure --silent --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
        --with-expat=${LIBEXPAT_PREFIX} \
        --prefix="${PREFIX}"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CC=clang CXX=clang++ \
    CFLAGS="-fPIC" \
    LDFLAGS="-L${OUTPUT_LIB}" \
    FREETYPE_CFLAGS="-I${OUTPUT_INCLUDE}/freetype2" FREETYPE_LIBS="-L${OUTPUT_LIB}/freetype2 -lfreetype" \
    ./configure --silent --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
        --with-expat=${LIBEXPAT_PREFIX} \
        --prefix="${PREFIX}"
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make --silent -j${JOBS}
make --silent install

# Copy headers and libraries
cp -R "${PREFIX}/include/fontconfig"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib/lib${LIBRARY_NAME}.a" "${OUTPUT_LIB}/${LIBRARY_NAME}/"

print_success "Build complete for ${LIBRARY_NAME}"
