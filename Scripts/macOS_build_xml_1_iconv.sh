#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libiconv.a
rm -f Libraries/macOS/libcharset.a

rm -rf Headers/iconv
mkdir Headers/iconv

# Switch to our build directory

cd ../source/macOS

rm -rf libiconv
mkdir libiconv
tar -xf ../libiconv.tar.gz -C libiconv --strip-components=1
cd libiconv

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

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --prefix="${PREFIX}"

make install

# Copy the header and library files.

cp -R _build_macos/include/* "${OUTPUT}/Headers/iconv"

cp _build_macos/lib/libiconv.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libcharset.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

