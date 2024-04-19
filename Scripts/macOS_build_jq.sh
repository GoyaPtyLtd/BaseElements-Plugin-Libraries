#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm Libraries/macOS/libjq.a
rm -rf Headers/jq

# Switch to our build directory

cd ../source/macOS/jq

# Remove old build directory contents
 
rm -rf _build_macos
mkdir _build_macos

# Build

autoreconf -i
CC=clang CXX=clang++ CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared --enable-all-static --enable-pthread-tls --without-oniguruma --prefix="$(pwd)/_build_macos"

make -s -j install

# Copy the header and library files.

cp -R ./_build_macos/include "${SRCROOT}/Headers/jq"

cp "_build_macos/lib/libjq.a" "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

cd "START"
