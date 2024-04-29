#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libturbojpeg.a
rm -rf Headers/libturbojpeg/*

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf libturbojpeg
mkdir libturbojpeg
tar -xf ../libturbojpeg.tar.gz  -C libturbojpeg --strip-components=1
cd libturbojpeg
mkdir _build_macos

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" cmake -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON

make install DESTDIR="./_build_macos"

# Copy the header and library files.

cp -R ./_build_macos/opt/libjpeg-turbo/include "${OUTPUT}/Headers/libturbojpeg"
cp ./_build_macos/opt/libjpeg-turbo/lib/libturbojpeg.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
