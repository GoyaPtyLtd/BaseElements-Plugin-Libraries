#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm Libraries/macOS/libjpeg.a
rm -rf Headers/libjpeg

# Switch to our build directory

cd ../source/macOS/libjpeg

# Remove old build directory contents
 
rm -rf _build_macos
mkdir _build_macos

# Build

./configure --host=x86_64 --prefix="$(pwd)/_build_macos" CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" --disable-shared

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --prefix="$(pwd)/_build_macos" --disable-shared --enable-static 

make -s -j install

# Copy the header and library files.

cp -R ./_build_macos/include "${SRCROOT}/Headers/libjpeg"
cp ./_build_macos/lib/libjpeg.a "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

cd "START"
