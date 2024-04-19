#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm Libraries/macOS/libiconv.a
rm Libraries/macOS/libcharset.a

rm Libraries/macOS/libxml2.a

rm Libraries/macOS/libxslt.a
rm Libraries/macOS/libexslt.a

# Remove old headers

rm -rf Headers/libxml/*
rm -rf Headers/libxslt/*
rm -rf Headers/iconv/*

#====libiconv====

# Switch to our build directory

cd ../source/macOS/libiconv

export ICONV=`pwd`

# Remove old build directory contents
 
rm -rf _build_macos
mkdir _build_macos

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --prefix="${$(pwd)}/_build_macos"

make -s -j install

# Copy the header and library files.

mkdir "${SRCROOT}/Headers/iconv"

cp -R _build_macos/include/*.h "${SRCROOT}/Headers/iconv"

cp _build_macos/lib/libiconv.a "${SRCROOT}/Libraries/macOS"
cp _build_macos/lib/libcharset.a "${SRCROOT}/Libraries/macOS"

#====libxml2====

# Switch to our build directory

cd ../libxml

# Remove old build directory contents
 
rm -rf _build_macos
mkdir _build_macos

export LIBXML=`pwd`

# Build

# used to be : CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --with-threads --without-python --without-zlib --without-lzma --with-iconv=../libiconv/_build_macos --prefix="${$(pwd)}/_build_macos"

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --with-threads --without-python --without-zlib --without-lzma --with-iconv --prefix="${$(pwd)}/_build_macos"

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/libxml2/libxml "${SRCROOT}/Headers"
cp _build_macos/lib/libxml2.a "${SRCROOT}/Libraries/macOS"

#====libxslt====

# Switch to our build directory

cd ../libxslt

# Remove old build directory contents
 
rm -rf _build_macos
mkdir _build_macos

# Build

./configure CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" --disable-shared --without-python --without-crypto --with-libxml-prefix="${LIBXML}/_build_macos" --prefix="${$(pwd)}/_build_macos"

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/libxslt "${SRCROOT}/Headers"
cp _build_macos/lib/libxslt.a "${SRCROOT}/Libraries/macOS"
cp _build_macos/lib/libexslt.a "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

cd "START"
