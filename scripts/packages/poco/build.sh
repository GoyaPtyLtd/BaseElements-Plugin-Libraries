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
#   OS
#   PLATFORM
#   PLATFORM_INCLUDE
#   PLATFORM_LIBS
#   PLATFORM_FRAMEWORKS
#   BUILD_LOG
build() {
    cd  "${PACKAGE_SRC}" || exit 1

    rm -rf _build*
    mkdir _build
    mkdir _build_x86_64
    mkdir _build_arm64
    mkdir _build_iPhone
    mkdir _build_iPhoneSim_x86
    mkdir _build_iPhoneSim_arm

    local PREFIX=${PWD}'/_build'
    local PREFIX_x86_64=${PWD}'/_build_x86_64'
    local PREFIX_arm64=${PWD}'/_build_arm64'
    local PREFIX_iPhone=${PWD}'/_build_iPhone'
    local PREFIX_iPhoneSim_x86=${PWD}'/_build_iPhoneSim_x86'
    local PREFIX_iPhoneSim_arm=${PWD}'/_build_iPhoneSim_arm'

    # Build
    rm -f "${BUILD_LOG}"
    print_ok "Building ..."
    (
        if [[ $PLATFORM = 'macOS' ]]; then

            #mac OS

            ./configure --cflags="-mmacosx-version-min=10.15" \
            --prefix="${PREFIX_x86_64}" \
            --no-sharedlibs --static --poquito --no-tests --no-samples \
            --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
            --include-path="${PLATFORM_INCLUDE}" --library-path="$PLATFORM_LIBS"

            make -j"${JOBS}" POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=x86_64 POCO_TARGET_OSARCH="${HOST}"
            make install POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=x86_64 POCO_TARGET_OSARCH="${HOST}"
            make -s distclean

            ./configure --cflags="-mmacosx-version-min=10.15" \
            --prefix="${PREFIX_arm64}" \
            --no-sharedlibs --static --poquito --no-tests --no-samples \
            --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
            --include-path="${PLATFORM_INCLUDE}" --library-path="${PLATFORM_LIBS}"

            make -j"${JOBS}" POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=arm64 POCO_TARGET_OSARCH="${HOST}"
            make install POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=arm64 POCO_TARGET_OSARCH="${HOST}"
            make -s distclean

            mkdir "${PREFIX}/lib"

            cp -R _build_x86_64/include/* "${PLATFORM_INCLUDE}"

            pushd "${PREFIX_x86_64}/lib" > /dev/null || exit 1  # cd "${PREFIX_x86_64}/lib"
            local libname
            for libname in *.a; do
                lipo -create "${PREFIX_x86_64}/lib/${libname}" "${PREFIX_arm64}/lib/${libname}" -output "${PREFIX}/lib/${libname}"
            done
            popd > /dev/null || exit 1                          # return to original directory

        : <<END_COMMENT
            #iOS

            ./configure --cflags="-miphoneos-version-min=15.0" \
            --prefix="${PREFIX_iPhone}" \
            --no-sharedlibs --static --poquito --no-tests --no-samples \
            --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
            --include-path="${PLATFORM_INCLUDE}" --library-path="${PLATFORM_LIBS}"

            make -j${JOBS} POCO_CONFIG=iPhone-clang-libc++ IPHONEOS_DEPLOYMENT_TARGET=15.0
            make install POCO_CONFIG=iPhone-clang-libc++ IPHONEOS_DEPLOYMENT_TARGET=15.0
            make -s distclean

            cp _build_iPhone/lib/libPocoCrypto.a "${OUTPUT}/Libraries/iOS"
            cp _build_iPhone/lib/libPocoFoundation.a "${OUTPUT}/Libraries/iOS"
            cp _build_iPhone/lib/libPocoJSON.a "${OUTPUT}/Libraries/iOS"
            cp _build_iPhone/lib/libPocoNet.a "${OUTPUT}/Libraries/iOS"
            cp _build_iPhone/lib/libPocoXML.a "${OUTPUT}/Libraries/iOS"
            cp _build_iPhone/lib/libPocoUtil.a "${OUTPUT}/Libraries/iOS"
            cp _build_iPhone/lib/libPocoZip.a "${OUTPUT}/Libraries/iOS"

            #iOS Simulator

            ./configure --cflags="-miphoneos-version-min=15.0" \
            --prefix="${PREFIX_iPhoneSim_arm}" \
            --no-sharedlibs --static --poquito --no-tests --no-samples \
            --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
            --include-path="${PLATFORM_INCLUDE}" --library-path="${PLATFORM_LIBS}"

            make -j${JOBS} POCO_CONFIG=iPhoneSimulator IPHONEOS_DEPLOYMENT_TARGET=15.0 POCO_HOST_OSARCH=arm64
            make install
            make -s distclean

            ./configure --cflags="-miphoneos-version-min=15.0" \
            --prefix="${PREFIX_iPhoneSim_x86}" \
            --no-sharedlibs --static --poquito --no-tests --no-samples \
            --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
            --include-path="${PLATFORM_INCLUDE}" --library-path="${PLATFORM_LIBS}"

            make -j"${JOBS}" POCO_CONFIG=iPhoneSimulator IPHONEOS_DEPLOYMENT_TARGET=15.0 POCO_HOST_OSARCH=x86_64
            make install
            make -s distclean
END_COMMENT


        elif [[ $OS = 'Linux' ]]; then

            ./configure --cflags=-fPIC \
            --config=Linux-clang \
            --prefix="${PREFIX}" \
            --no-sharedlibs --static --poquito --no-tests --no-samples \
            --omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
            --include-path="${PLATFORM_INCLUDE}" --library-path="${PLATFORM_LIBS}"

            make -j"${JOBS}"
            make install

        fi
    ) >> "${BUILD_LOG}" 2>&1 &
    wait_progress $!
    return_code=$?
    if [[ $return_code -ne 0 ]]; then
        exit 1
        print_error "Build failed. Return code: $return_code"
    fi

    print_ok "Build complete."

    # Copy the header and library files.

    cp -R _build/include/* "${PLATFORM_INCLUDE}/"

    pushd _build/lib > /dev/null || exit 1  # cd "${PREFIX}/lib"
    cp "${LIBRARIES[@]}" "${PLATFORM_LIBS}"
    popd > /dev/null || exit 1              # return to original directory

}


# --- BOILERPLATE ---
# Source this after required functions are defined.
source ../build-functions
# --- BOILERPLATE ---
