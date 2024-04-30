#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libjpeg.a
rm -rf Headers/libjpeg

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libjpeg
mkdir libjpeg
tar -xf ../libjpeg.tar.gz  -C libjpeg --strip-components=1
cd libjpeg

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'_build_macos'

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --host=x86_64 --prefix="$PREFIX"  --disable-shared --enable-static
make -s -j install

# Copy the header and library files.

cp -R ./_build_macos/include "${OUTPUT}/Headers/libjpeg"
cp ./_build_macos/lib/libjpeg.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
