#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and Headers

rm -f Libraries/macOS/libde265.a
rm -rf Headers/libde265
mkdir Headers/libde265

# Switch to our build directory and clean out anything old

cd ../source/macOS
rm -rf libde265
mkdir libde265
tar -xf ../libde265.tar.gz  -C libde265 --strip-components=1
cd libde265

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

cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DBUILD_SHARED_LIBS=OFF -DENABLE_SDL=FALSE -DENABLE_SHERLOCK265=FALSE -DENABLE_DECODER=OFF -DCMAKE_OSX_DEPLOYMENT_TARGET="10.15" ./
make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/libde265/* "${OUTPUT}/Headers/libde265"
cp _build_macos/lib/libde265.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
