#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm macOS/libjansson.a

# Remove old headers

rm -rf Headers/jansson.h
rm -rf Headers/jansson_config.h

# Switch to our build directory

cd ../source/macOS/jansson

# Remove old build directory contents
 
mkdir _build_macos
rm -rf _build_macos/*

# Build

autoreconf -fi

./configure --host=x86_64 --prefix="$(pwd)/_build_macos" CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" --disable-shared
make -s -j install

# Copy the header and library files.

cp _build_macos/include/jansson.h "${SRCROOT}/Headers/"
cp _build_macos/include/jansson_config.h "${SRCROOT}/Headers/"

cp _build_macos/lib/libjansson.a "${SRCROOT}/Libraries/macOS/"

# Return to source/macOS directory

cd "START"
