#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libturbojpeg.a
rm -rf Headers/libturbojpeg
mkdir Headers/libturbojpeg

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libturbojpeg
mkdir libturbojpeg
tar -xf ../libturbojpeg.tar.gz  -C libturbojpeg --strip-components=1
cd libturbojpeg

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

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON ./
make install DESTDIR="${PREFIX}"

# Copy the header and library files.

cp -R _build_macos/opt/libjpeg-turbo/include/* "${OUTPUT}/Headers/libturbojpeg"

cp _build_macos/opt/libjpeg-turbo/lib/libturbojpeg.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/opt/libjpeg-turbo/lib/libjpeg.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
