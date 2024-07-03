#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libfontconfig.a
rm -rf Headers/fontconfig
mkdir Headers/fontconfig

# Switch to our build directory

cd ../source/macOS

rm -rf fontconfig
mkdir fontconfig
tar -xf ../fontconfig.tar.gz -C fontconfig --strip-components=1
cd fontconfig

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

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure \
--disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
--prefix="${PREFIX}" \
FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/macOS -lfreetype" \
LDFLAGS="-L${OUTPUT}/Libraries/macOS"

make -j install

# Copy the header and library files.

cp -R _build_macos/include/fontconfig/* "${OUTPUT}/Headers/fontconfig"
cp _build_macos/lib/libfontconfig.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}
