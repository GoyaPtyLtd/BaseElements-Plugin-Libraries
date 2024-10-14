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
#   PACKAGE_SRC      - from fetch()
#   PLATFORM
#   PLATFORM_INCLUDE
#   PLATFORM_LIBS
#   PLATFORM_FRAMEWORKS
#   BUILD_LOG
build() {
    cd "${PACKAGE_SRC}" || exit 1

    rm -rf _build
    mkdir _build
    local PREFIX=${PWD}'/_build'

    # Build
    rm -f "${BUILD_LOG}"
    print_ok "Building ..."
    (
        if [[ $PLATFORM =~ ^macos ]]; then

            CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
            ./configure --enable-static --enable-shared=NO \
            --with-libiconv-prefix="${PLATFORM_ROOT}" \
            --prefix="${PREFIX}"

        elif [[ $PLATFORM =~ ^ubuntu ]]; then

            CC=clang CXX=clang++ \
            CFLAGS="-fPIC" \
            ./configure --enable-static --enable-shared=NO \
            --with-libiconv-prefix="${PLATFORM_ROOT}" \
            --prefix="${PREFIX}"

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

    cp -R _build/include/* "${PLATFORM_INCLUDE}/"
    cp _build/lib/libunistring.a "${PLATFORM_LIBS}/"

}

# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
