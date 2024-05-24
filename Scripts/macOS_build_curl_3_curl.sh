#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libcurl.a
rm -rf Headers/curl
mkdir Headers/curl

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`'/_build_macos'
export PREFIX_ios=`pwd`'/_build_ios'
export PREFIX_iosSimulator=`pwd`'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`'/_build_iosSimulatorx86'

# Build macOS

export MAC_SDK=$(xcrun -sdk macosx --show-sdk-path)

./configure --quiet --host=x86_64-apple-darwin CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -isysroot ${MAC_SDK}" CPPFLAGS=" -I${OUTPUT}/Headers -I${OUTPUT}/Headers/libssh2 -I${OUTPUT}/Headers/openssl" LDFLAGS=" -L${OUTPUT}/Libraries/macOS" LIBS="-ldl" --disable-dependency-tracking --enable-static --disable-shared --with-ssl --with-zlib --with-libssh2 --without-tests --without-libpsl --without-brotli --without-zstd --prefix="${PREFIX}"

# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others
# TODO also investigate libidn which is also in podofo

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/curl/* "${OUTPUT}/Headers/curl"
cp _build_macos/lib/libcurl.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}

