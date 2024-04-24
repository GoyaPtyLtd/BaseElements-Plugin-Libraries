#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libheif.a
rm -rf Headers/libheif

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libheif
mkdir libheif
tar -xf ../libheif.tar.gz  -C libheif --strip-components=1
cd libheif
mkdir _build_macos

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" cmake -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DX265_INCLUDE_DIR="${OUTPUT}/Headers/libde265" X265_LIBRARY="${OUTPUT}/Libraries/macOS" ./

make install DESTDIR="./_build_macos"

# Copy the header and library files.

cp -R ./_build_macos/include "${OUTPUT}/Headers/libheif"
cp ./_build_macos/lib/libheif.a "${OUTPUT}/Libraries/macOS"

# Return to source/macOS directory

cd ${SRCROOT}
