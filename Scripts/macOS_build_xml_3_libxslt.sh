#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libxslt.a
rm Libraries/macOS/libexslt.a

rm -rf Headers/libxslt
mkdir Headers/libxslt

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libxslt
mkdir libxslt
tar -xf ../libxslt.tar.gz -C libxslt --strip-components=1
cd libxslt

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

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./autogen.sh --disable-shared --without-python --without-crypto --with-libxml-prefix="../libxml/_build_macos" --prefix="${PREFIX}"

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/libxslt/* "${OUTPUT}/Headers/libxslt"
cp _build_macos/lib/libxslt.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libexslt.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

