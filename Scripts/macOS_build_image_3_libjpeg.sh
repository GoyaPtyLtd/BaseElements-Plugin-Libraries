#!/bin/bash -E

export START=`pwd`

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

# Build

./configure --host=x86_64 --prefix="${$(pwd)}/_build_macos_arm64" CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" --disable-shared

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --prefix="$(pwd)/_build_macos" --disable-shared --enable-static

make -s -j install

# Copy the header and library files.

cp -R ./_build_macos/include "${OUTPUT}/Headers/libjpeg"
cp ./_build_macos/lib/libjpeg.a "${OUTPUT}/Libraries/macOS"

# Return to source/macOS directory

cd "${START}"
