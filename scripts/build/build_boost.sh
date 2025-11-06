#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, interactive mode, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

LIBRARY_NAME="boost"
ARCHIVE_NAME="boost.tar.gz"

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

# List of boost libraries to build
LIBS=(
    libboost_atomic.a
    libboost_date_time.a
    libboost_filesystem.a
    libboost_program_options.a
    libboost_regex.a
    libboost_thread.a
)

# Bootstrap and build
interactive_prompt \
    "Ready to bootstrap and build ${LIBRARY_NAME}" \
    "Platform: ${PLATFORM}" \
    "Build directory: ${BUILD_DIR}" \
    "Libraries: ${LIBS[*]}"

print_info "Bootstrapping ${LIBRARY_NAME}..."
./bootstrap.sh --with-toolset=clang --with-libraries="atomic,chrono,date_time,exception,filesystem,program_options,regex,system,thread"

# Configure build flags
CFLAGS=()
CXXFLAGS=()
LINKFLAGS=()

if [[ $OS = 'Darwin' ]]; then
    # macOS universal build
    print_info "Configuring for macOS (universal: arm64 + x86_64)..."
    CXXFLAGS+=(
        -arch arm64
        -arch x86_64
        '-mmacosx-version-min=10.15'
        '-stdlib=libc++'
    )
    LINKFLAGS+=(
        '-stdlib=libc++'
    )

    # iOS build directories (preserved for future use)
    : <<END_COMMENT
    mkdir _build_iOS
    mkdir _build_iOS_Sim
    PREFIX_iOS=${PWD}/_build_iOS
    PREFIX_iOS_Sim=${PWD}/_build_iOS_Sim
END_COMMENT

elif [[ $OS = 'Linux' ]]; then
    # Linux build
    print_info "Configuring for Linux..."
    CFLAGS+=(
        -fPIC
    )
    CXXFLAGS+=(
        -fPIC
    )
fi

print_info "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
./b2 toolset=clang \
    cflags="${CFLAGS[*]}" \
    cxxflags="${CXXFLAGS[*]}" \
    linkflags="${LINKFLAGS[*]}" \
    address-model=64 link=static runtime-link=static \
    --with-atomic --with-chrono --with-date_time --with-exception \
    --with-filesystem --with-program_options --with-regex --with-system --with-thread \
    --prefix="${PREFIX}" -j${JOBS} \
    install

# Copy headers and libraries
interactive_prompt \
    "Ready to copy headers and libraries" \
    "Headers: ${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" \
    "Libraries: ${OUTPUT_LIB}/${LIBRARY_NAME}/"

cp -R "${PREFIX}/include/boost"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true

for LIB in "${LIBS[@]}"; do
    cp "${PREFIX}/lib/${LIB}" "${OUTPUT_LIB}/${LIBRARY_NAME}/"
done

# iOS build (preserved for future use)
: <<END_COMMENT
# Build iOS
#cp -R dist/boost.xcframework "${OUTPUT_LIB}/iOS"
END_COMMENT

print_success "Build complete for ${LIBRARY_NAME}"
