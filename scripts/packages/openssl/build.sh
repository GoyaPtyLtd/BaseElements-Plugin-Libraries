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
    cd "${PACKAGE_SOURCE_DIR}" || exit 1

    rm -rf _build
    mkdir -p _build
    local PREFIX=${PWD}'/_build'

    # Build.
    rm -rf "${BUILD_LOG}"
    print_ok "Building ..."
    (
        if [[ $PLATFORM = 'macOS' ]]; then

            mkdir _build_x86_64
            local PREFIX_x86_64=${PWD}'/_build_x86_64'

            CFLAGS="-mmacosx-version-min=10.15" \
            ./configure darwin64-x86_64-cc no-shared no-docs no-tests \
            --prefix="${PREFIX_x86_64}"

            make -j${JOBS}
            make install
            make -s distclean

            mkdir _build_arm64
            local PREFIX_arm64=${PWD}'/_build_arm64'

            CFLAGS="-mmacosx-version-min=10.15" \
            ./configure darwin64-arm64-cc no-shared no-docs no-tests \
            --prefix="${PREFIX_arm64}"

            make -j${JOBS}
            make install
            make -s distclean

            mkdir "${PREFIX}/lib"

            lipo -create "${PREFIX_x86_64}/lib/libcrypto.a" "${PREFIX_arm64}/lib/libcrypto.a" -output "${PREFIX}/lib/libcrypto.a"
            lipo -create "${PREFIX_x86_64}/lib/libssl.a" "${PREFIX_arm64}/lib/libssl.a" -output "${PREFIX}/lib/libssl.a"

        elif [[ $OS = 'Linux' ]]; then

            CC=clang CXX=clang++ \
            ./Configure linux-generic64 no-shared no-docs no-tests \
            --prefix="${PREFIX}"
            make -j${JOBS}
            make install_sw

        fi
    ) >> "${BUILD_LOG}" 2>&1 &
    wait_progress $!
    return_code=$?

    if [[ $return_code -ne 0 ]]; then
        print_error "Build failed. Return code: $return_code"
        exit 1
    fi

    print_ok "Build complete."


    # Copy the header and library files.

    if [[ $PLATFORM = 'macOS' ]]; then
        cp -R _build_x86_64/include/* "${HEADERS_ROOT}/"
    else
        cp -R _build/include/* "${HEADERS_ROOT}/"
    fi

    cp _build/lib/libcrypto.a "${LIBRARIES_PLATFORM_ROOT}"
    cp _build/lib/libssl.a "${LIBRARIES_PLATFORM_ROOT}"
}


# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
