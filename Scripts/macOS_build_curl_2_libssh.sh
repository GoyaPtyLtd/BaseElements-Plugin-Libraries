#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libssh2.a
rm -rf Headers/libssh2
mkdir Headers/libssh2

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C libssh --strip-components=1
cd libssh

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

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -I${OUTPUT}/Headers -I${OUTPUT}/Headers/openssl" LDFLAGS="-L${OUTPUT}/Libraries/macOS/" LIBS="-ldl" ./configure --disable-shared --disable-examples-build --prefix="${PREFIX}" -exec-prefix="${PREFIX}" --with-libz --with-crypto=openssl
make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/* "${OUTPUT}/Headers/libssh2"
cp _build_macos/lib/libssh2.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}
