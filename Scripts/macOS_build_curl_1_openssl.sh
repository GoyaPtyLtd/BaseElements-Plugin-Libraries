#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libcrypto.a
rm Libraries/macOS/libssl.a
rm -rf Headers/openssl
mkdir Headers/openssl

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

#====openssl====

# Switch to our build directory

rm -rf openssl
mkdir openssl
tar -xf ../openssl.tar.gz -C openssl --strip-components=1
cd openssl

mkdir _build_macos
mkdir _build_macos_x86_64
mkdir _build_macos_arm64
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`'/_build_macos'
export PREFIX_x86_64=`pwd`'/_build_macos_x86_64'
export PREFIX_arm64=`pwd`'/_build_macos_arm64'
export PREFIX_ios=`pwd`'/_build_ios'
export PREFIX_iosSimulator=`pwd`'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`'/_build_iosSimulatorx86'

# Build macOS

# this build seems to fail with "make -j" so we've left that out

#first build is install so we get headers
CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-x86_64-cc no-engine no-shared --prefix="${PREFIX_x86_64}"
make -s install
make -s -j distclean

#install_sw leaves out headers
CFLAGS="-mmacosx-version-min=10.15" ./configure darwin64-arm64-cc no-engine no-shared --prefix="${PREFIX_arm64}"
make -s install_sw
make -s -j distclean

lipo -create "${PREFIX_x86_64}/lib/libcrypto.a" "${PREFIX_arm64}/lib/libcrypto.a" -output "${PREFIX}/libcrypto.a"
lipo -create "${PREFIX_x86_64}/lib/libssl.a" "${PREFIX_arm64}/lib/libssl.a" -output "${PREFIX}/libssl.a"

# Copy the header and library files.

cp -R _build_macos_x86_64/include/openssl/* "${OUTPUT}/Headers/openssl"

cp _build_macos/libcrypto.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/libssl.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}
