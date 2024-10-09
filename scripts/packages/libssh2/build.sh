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
#   HOST
#   HEADERS_ROOT
#   LIBRARIES_PLATFORM_ROOT
#   FRAMEWORKS_ROOT
#   BUILD_LOG
build() {
    cd "${PACKAGE_SOURCE_DIR}" || exit 1

    rm -rf _build
    mkdir _build
    local PREFIX=${PWD}'/_build'

    # Build
    rm -rf "${BUILD_LOG}"
    print_ok "Building ..."
    (
        if [[ $PLATFORM = 'macOS' ]]; then

            CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" \
            CPPFLAGS="-I${HEADERS_ROOT}" \
            LDFLAGS="-L${LIBRARIES_PLATFORM_ROOT}" LIBS="-ldl" \
            ./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
            --with-libz \
            --with-crypto=openssl \
            --host="${HOST}" \
            --prefix="${PREFIX}"

        elif [[ $OS = 'Linux' ]]; then

            CC=clang CXX=clang++ \
            CFLAGS=-fPIC \
            CPPFLAGS="-I${HEADERS_ROOT}" \
            LDFLAGS="-L${LIBRARIES_PLATFORM_ROOT}" LIBS="-ldl" \
            ./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
            --with-libz \
            --with-crypto=openssl \
            --prefix="${PREFIX}"

        fi

        make -j${JOBS}
        make install

    ) >> "${BUILD_LOG}" 2>&1 &
    wait_progress $!
    return_code=$?

    if [[ $return_code -ne 0 ]]; then
        print_error "Build Task Test failed. Return code: $return_code"
        exit 1
    fi

    print_ok "Build complete."


    # Copy the header and library files.

    cp -R _build/include/* "${HEADERS_ROOT}"
    cp _build/lib/libssh2.a "${LIBRARIES_PLATFORM_ROOT}"
}

# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
