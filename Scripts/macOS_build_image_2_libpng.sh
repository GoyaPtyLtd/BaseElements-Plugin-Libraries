#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libpng.a
rm -rf Headers/libpng
mkdir Headers/libpng

# Switch to our build directory

cd ../source/macOS

rm -rf libpng
mkdir libpng
tar -xf ../libpng.tar.gz  -C libpng --strip-components=1
cd libpng

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`'/_build_macos'
export PREFIX_x86_64=`pwd`'/_build_macos_x86_64'
export PREFIX_arm64=`pwd`'/_build_macos_arm64'
export PREFIX_ios=`pwd`'/_build_ios'
export PREFIX_iosSimulator=`pwd`'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`'/_build_iosSimulatorx86'

# Build macOS

CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" ./configure \
--disable-shared --disable-dependency-tracking --disable-silent-rules \
--host="aarch64-apple-darwin" --prefix="${PREFIX_x86_64}"

make install
make -s -j distclean

CFLAGS="-arch arm64 -mmacosx-version-min=10.15" ./configure \
--disable-shared --disable-dependency-tracking --disable-silent-rules \
--host="aarch64-apple-darwin" --prefix="${PREFIX_arm64}"

make install
make -s -j distclean

# Copy the header and library files.

cp -R _build_macos_x86_64/include/libpng16/* "${OUTPUT}/Headers/libpng"

lipo -create "${PREFIX_x86_64}/lib/libpng16.a" "${PREFIX_arm64}/lib/libpng16.a" -output "${PREFIX}/libpng16.a"
cp _build_macos/libpng16.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
