#!/usr/bin/env bash

# --- BOILERPLATE ---
# Determine this script's directory.
REALDIR=$(dirname "$(realpath "$0")")
cd "${REALDIR}" || exit 1
# --- BOILERPLATE ---

# Build package.
#
# Almost every package will need to define a build() function.
#
# Only a virtual package does not define a build() function. It is just used
# as a way to group DEPENDENCIES in the "package" file.
#
# Uses global variables:
#   PACKAGE_SOURCE_DIR      - from fetch()
#   OS
#   PLATFORM
#   HEADERS_ROOT
#   LIBRARIES_PLATFORM_ROOT
#   FRAMEWORKS_ROOT
#   BUILD_LOG
build() {
    cd "$PACKAGE_SOURCE_DIR" || exit 1

    rm -rf _build
    mkdir -p _build
    local PREFIX=${PWD}'/_build'

    # Build

    rm -rf "${BUILD_LOG}"
    print_ok "Building ..."
    (

        if [[ $PLATFORM = 'macOS' ]]; then

            CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
            ./configure --static --prefix="${PREFIX}"

        elif [[ $OS = 'Linux' ]]; then

            CC=clang CXX=clang++ \
            CFLAGS="-fPIC" \
            ./configure --static --prefix="${PREFIX}"

        fi

        make -j${JOBS}
        make install

    ) >> "${BUILD_LOG}" 2>&1 &
    wait_progress $!
    return_code=$?

    if [[ $return_code -ne 0 ]]; then
        print_error "Build failed. Return code: $return_code"
        exit 1
    fi

    print_ok "Build complete."


    # Copy the header and library files.

    cp -R _build/include/* "${HEADERS_ROOT}/"
    cp _build/lib/libz.a "${LIBRARIES_PLATFORM_ROOT}/"
}


# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
