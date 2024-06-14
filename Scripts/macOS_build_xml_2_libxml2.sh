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

export ICONV=`pwd`'/iconv/_build_macos'

rm -rf libxml
mkdir libxml
tar -xf ../libxml.tar.gz -C libxml --strip-components=1
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
export LIBXML=`pwd`

# Build macOS

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./autogen.sh --disable-shared --with-threads --without-python --without-zlib --without-lzma --with-iconv=${ICONV} --prefix="${PREFIX}"

make -j install

#Need to change this so it finds my installed version and not the SDK supplied one.

sed -i '' -e 's|#include <iconv\.h\>|#include <iconv/iconv.h>|g' "${PREFIX}/include/libxml2/libxml/encoding.h"

# Copy the header and library files.

cp -R _build_macos/include/libxml2/libxml/* "${OUTPUT}/Headers/libxml"
cp _build_macos/lib/libxml2.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}
