#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libjq.a
rm -rf Headers/jq
mkdir Headers/jq

# Switch to our build directory

cd ../source/macOS

rm -rf jq
mkdir jq
tar -xf ../jq.tar.gz  -C jq --strip-components=1
cd jq

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

./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared --enable-all-static --enable-pthread-tls --without-oniguruma --prefix="${PREFIX}"

make -j install

# Copy the header and library files.

cp -R _build_macos/include/* "${OUTPUT}/Headers/jq"
cp _build_macos/lib/libjq.a "${OUTPUT}/Libraries/macOS"

# jq seems to require the version.h file, but doesn't put it into the prefix.

cp src/version.h "${OUTPUT}/Headers/jq"

# Return to source directory

cd ${SRCROOT}
