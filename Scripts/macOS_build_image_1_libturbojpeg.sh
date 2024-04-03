#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm macOS/libturbojpeg.a

# Remove old headers

rm -rf Headers/libturbojpeg/*

# Switch to our build directory

cd ../source/macOS/libjpeg

# Remove old build directory contents
 
mkdir _build_macos
rm -rf _build_macos/*

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" cmake -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON

make install DESTDIR="./_build_macos"

# Copy the header and library files.

cp -R ./_build_macos/opt/libjpeg-turbo/include "${SRCROOT}/Headers/libturbojpeg"
cp ./_build_macos/opt/libjpeg-turbo/lib/libturbojpeg.a "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

cd "START"
