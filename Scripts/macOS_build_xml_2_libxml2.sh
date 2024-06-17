#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libxml2.a

rm -rf Headers/libxml
mkdir Headers/libxml

# Switch to our build directory

cd ../source/macOS

export ICONV=`pwd`'/libiconv/_build_macos'

rm -rf libxml
mkdir libxml
tar -xf ../libxml.tar.xz -C libxml --strip-components=1
cd libxml

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

export CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" 
./configure --disable-shared --with-threads --without-python --with-iconv="${ICONV}" --prefix="${PREFIX}"

make -j install

# Copy the header and library files.

cp -R _build_macos/include/libxml2/libxml/* "${OUTPUT}/Headers/libxml"
cp _build_macos/lib/libxml2.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}
