#!/bin/bash
set -e

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/linux/libjansson.a
rm -rf Headers/jansson.h
rm -rf Headers/jansson_config.h

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf jansson
mkdir jansson
tar -xf ../jansson.tar.gz -C jansson --strip-components=1
cd jansson
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

autoupdate
autoreconf -fi

./configure --host=x86_64 --prefix="${PREFIX}" CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" --disable-shared

make -s -j install

# Copy the library files.

cp _build_linux/include/jansson.h "${OUTPUT}/Headers/"
cp _build_linux/include/jansson_config.h "${OUTPUT}/Headers/"

cp _build_linux/lib/libjansson.a "${OUTPUT}/Libraries/macOS/"

# Return to source directory

cd ${SRCROOT}
