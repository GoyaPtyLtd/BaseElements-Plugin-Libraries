#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm macOS/libjq.a

# Remove old headers

rm -rf Headers/jq/*

# Switch to our build directory

cd ../source/macOS/jq

# Remove old build directory contents
 
mkdir _build_macos
rm -rf _build_macos/*

# Build

autoreconf -i
CC=clang CXX=clang++ CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared --enable-all-static --enable-pthread-tls --without-oniguruma --prefix="$(pwd)/_build_macos"

make -s -j install

# Copy the header and library files.

cp -R ./_build_macos/include "${SRCROOT}/Headers/jq"

cp "_build_macos/lib/libjq.a" "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

cd "START"
