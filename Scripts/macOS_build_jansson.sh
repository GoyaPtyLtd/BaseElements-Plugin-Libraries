#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libjansson.a
rm -rf Headers/jansson.h
rm -rf Headers/jansson_config.h

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf jansson
mkdir jansson
tar -xf ../jansson.tar.gz -C jansson --strip-components=1
cd jansson
mkdir _build_macos

# Build

autoupdate
autoreconf -fi

./configure --host=x86_64 --prefix="${$(pwd)}/_build_macos" CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" --disable-shared

make -s -j install

# Copy the header and library files.

cp _build_macos/include/jansson.h "${OUTPUT}/Headers/"
cp _build_macos/include/jansson_config.h "${OUTPUT}/Headers/"

cp _build_macos/lib/libjansson.a "${OUTPUT}/Libraries/macOS/"

# Return to source directory

cd ${SRCROOT}
