#!/usr/bin/env bash

# --- BOILERPLATE ---
# Determine this script's directory.
REALDIR=$(dirname "$(realpath "$0")")
cd "${REALDIR}" || exit 1
# --- BOILERPLATE ---

#
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

    rm -rf _build*
    mkdir _build
    mkdir _build/lib
    local PREFIX=${PWD}'/_build'

    # Build
    rm -rf "${BUILD_LOG}"
    print_ok "Building ..."
    (
        if [[ $PLATFORM =~ ^macos ]]; then

            mkdir _build_x86_64
            local PREFIX_x86_64=${PWD}'/_build_x86_64'

            CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
            CPPFLAGS="-I${PLATFORM_INCLUDE}" \
            LDFLAGS="-L${PLATFORM_LIBS}" LIBS="-ldl" \
            ./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
            --without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2  \
            --with-zlib --with-openssl --with-libssh2 --with-nghttp \
            --prefix="${PREFIX_x86_64}" \
            --host="${HOST}"

            make -j${JOBS}
            make install
            make -s distclean

            mkdir _build_arm64
            local PREFIX_arm64=${PWD}'/_build_arm64'

            CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
            CPPFLAGS="-I${PLATFORM_INCLUDE}" \
            LDFLAGS="-L${PLATFORM_LIBS}" LIBS="-ldl" \
            ./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
            --without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2  \
            --with-zlib --with-openssl --with-libssh2 --with-nghttp \
            --prefix="${PREFIX_arm64}" \
            --host="${HOST}"

            make -j${JOBS}
            make install
            make -s distclean

            lipo -create "${PREFIX_x86_64}/lib/libcurl.a" "${PREFIX_arm64}/lib/libcurl.a" -output "${PREFIX}/lib/libcurl.a"

            # TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others
            # TODO also investigate libidn which is also in podofo

        elif [[ $PLATFORM =~ ^ubuntu ]]; then

            CC=clang CXX=clang++ \
            CPPFLAGS="-I${PLATFORM_INCLUDE}" \
            LDFLAGS="-L${PLATFORM_LIBS}" LIBS="-ldl" \
            ./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
            --without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 \
            --with-zlib --with-openssl --with-libssh2 --with-nghttp \
            --prefix="${PREFIX}"

            make -j${JOBS}
            make install

        fi
    ) >> "${BUILD_LOG}" 2>&1 &
    wait_progress $!
    return_code=$?

    if [[ $return_code -ne 0 ]]; then
        print_error  "Build failed. Return code: $return_code"
        exit 1
    fi


    # Copy the header and library files.

    if [[ $PLATFORM =~ ^macos ]]; then
        cp -R _build_x86_64/include/* "${PLATFORM_INCLUDE}"
    else
        cp -R _build/include/* "${PLATFORM_INCLUDE}"
    fi

    cp _build/lib/libcurl.a "${PLATFORM_LIBS}"

}



# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
