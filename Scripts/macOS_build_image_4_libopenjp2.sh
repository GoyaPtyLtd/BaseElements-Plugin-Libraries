#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libopenjp2.a
rm -rf Headers/libopenjp2
mkdir Headers/libopenjp2

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libopenjp2
mkdir libopenjp2
tar -xf ../libopenjp2.tar.gz  -C libopenjp2 --strip-components=1
cd libopenjp2

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

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_LIBRARY_PATH:path="${OUTPUT}/Libraries/macOS" -DCMAKE_INCLUDE_PATH:path="${OUTPUT}/Headers" ./
make install DESTDIR="${PREFIX}"

# Copy the header and library files.

cp -R _build_macos/usr/local/include/openjpeg-2.5/* "${OUTPUT}/Headers/libopenjp2"
cp _build_macos/usr/local/lib/libopenjp2.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
