# Build Script Template

This document describes the standard pattern for build scripts in this repository.

## Overview

All build scripts should:
1. Source `_build_common.sh` for platform detection, paths, colors, and helpers
2. Extract source to `output/platforms/${PLATFORM}/src/`
3. Build libraries
4. Copy outputs to `output/platforms/${PLATFORM}/include/` and `output/platforms/${PLATFORM}/lib/`

## Standard Script Structure

```bash
#!/bin/bash
set -e

# Source common build functionality (platform detection, paths, colors, helpers)
# This allows the script to be run standalone. When called from 2_build.sh,
# variables are already exported, but sourcing again is harmless.
source "$(dirname "$0")/_build_common.sh" "$@"

# Library-specific variables
LIBRARY_NAME="example"  # CHANGE THIS
ARCHIVE_NAME="example.tar.gz"  # CHANGE THIS

print_header "Starting $(basename "$0") Build"

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

# Configure
if [[ $OS = 'Darwin' ]]; then
    # macOS universal build (arm64 + x86_64)
    echo "Configuring for macOS (universal: arm64 + x86_64)..."
    CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
    CXXFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
    ./configure \
        --disable-shared \
        --enable-static \
        --prefix="${PREFIX}"
    
elif [[ $OS = 'Linux' ]]; then
    # Linux build
    echo "Configuring for Linux..."
    CC=clang CXX=clang++ \
    CFLAGS="-fPIC" \
    CXXFLAGS="-fPIC" \
    ./configure \
        --disable-shared \
        --enable-static \
        --prefix="${PREFIX}"
fi

# Build
echo "Building ${LIBRARY_NAME} (${JOBS} parallel jobs)..."
make -j${JOBS}
make install

# Copy headers and libraries
cp -R "${PREFIX}/include"/* "${OUTPUT_INCLUDE}/${LIBRARY_NAME}/" 2>/dev/null || true
cp "${PREFIX}/lib"/*.a "${OUTPUT_LIB}/${LIBRARY_NAME}/" 2>/dev/null || true

print_success "Build complete for ${LIBRARY_NAME}"
```

## Available Helper Functions from _build_common.sh

- `print_header "Title"` - Print a colored section header
- `print_success "Message"` - Print a success message in green

## Available Variables from _build_common.sh

All variables are exported and available to subprocesses:

### Platform Detection
- `OS` - Operating system (Linux|Darwin)
- `ARCH` - Architecture (x86_64|aarch64|arm64)
- `PLATFORM` - Platform name (ubuntu20_04-x86_64, macos-arm64-x86_64, etc.)
- `JOBS` - Number of parallel build jobs (CPU count + 1)

### Paths
- `PROJECT_ROOT` - Root directory of the repository
- `SOURCE_BASE` - Base source directory (`${PROJECT_ROOT}/source`)
- `OUTPUT_BASE` - Base output directory (`${PROJECT_ROOT}/output`)
- `SOURCE_ARCHIVES` - Directory containing downloaded archives (`${PROJECT_ROOT}/source`)
- `OUTPUT_DIR` - Platform output directory (`${PROJECT_ROOT}/output/platforms/${PLATFORM}`)
- `OUTPUT_INCLUDE` - Headers directory (`${OUTPUT_DIR}/include`)
- `OUTPUT_LIB` - Libraries directory (`${OUTPUT_DIR}/lib`)
- `OUTPUT_SRC` - Extracted source directory (`${OUTPUT_DIR}/src`)

## Key Changes from Old Scripts

1. **No platform detection code** - Use `_build_common.sh` instead
2. **No hardcoded paths** - Use exported variables from `_build_common.sh`
3. **New directory structure** - Extract to `OUTPUT_SRC`, output to `OUTPUT_INCLUDE` and `OUTPUT_LIB/${LIBRARY_NAME}/`
4. **No old platform names** - Use new naming (ubuntu20_04-x86_64, not linux/linuxARM)
5. **Consistent error handling** - Always use `set -e` at the top
6. **Single source file** - Use `_build_common.sh` for all common functionality (platform detection, paths, colors, helpers)

## Example: build_jq.sh

See `build_jq.sh` for a complete working example following this pattern.


