#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libfreetype.a
rm -rf Headers/freetype2
mkdir Headers/freetype2

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf freetype
mkdir freetype
tar -xf ../freetype.tar.gz -C freetype --strip-components=1
cd freetype

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

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --quiet --disable-shared --with-png=no --with-bzip2=no --with-harfbuzz=no --with-png=no --with-zlib=no --prefix=${PREFIX}
make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/freetype2/* "${OUTPUT}/Headers/freetype2"
cp _build_macos/lib/libfreetype.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}
