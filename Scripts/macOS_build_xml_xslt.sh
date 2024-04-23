#!/bin/bash -E

export START=`pwd`

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libiconv.a
rm Libraries/macOS/libcharset.a

rm Libraries/macOS/libxml2.a

rm Libraries/macOS/libxslt.a
rm Libraries/macOS/libexslt.a

# Remove old headers

rm -rf Headers/iconv/*
rm -rf Headers/libxml/*
rm -rf Headers/libxslt/*

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

#====libiconv====

# Switch to our build directory

rm -rf libiconv
mkdir libiconv
tar -xf ../libiconv.tar.gz -C libiconv --strip-components=1
cd libiconv
mkdir _build_macos

export ICONV=`pwd`

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --prefix="${$(pwd)}/_build_macos"

make install

# Copy the header and library files.

mkdir "${OUTPUT}/Headers/iconv"

cp -R _build_macos/include/*.h "${OUTPUT}/Headers/iconv"

cp _build_macos/lib/libiconv.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libcharset.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====libxml2====

# Switch to our build directory

rm -rf libxml
mkdir libxml
tar -xf ../libxml.tar.gz -C libxml --strip-components=1
cd libxml
mkdir _build_macos
 
export LIBXML=`pwd`

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./autogen.sh --disable-shared --with-threads --without-python --without-zlib --without-lzma --with-iconv=${ICONV}/_build_macos --prefix="${$(pwd)}/_build_macos"

make -s -j install

#Need to change this so it finds my installed version and not the SDK supplied one.

sed -i '' -e 's|#include <iconv\.h\>|#include <iconv/iconv.h>|g' _build_macos/include/libxml2/libxml/encoding.h

# Copy the header and library files.

cp -R _build_macos/include/libxml2/libxml "${OUTPUT}/Headers"
cp _build_macos/lib/libxml2.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====libxslt====

# Switch to our build directory

rm -rf libxslt
mkdir libxslt
tar -xf ../libxslt.tar.gz -C libxslt --strip-components=1
cd libxslt
mkdir _build_macos

# Build

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./autogen.sh --disable-shared --without-python --without-crypto --with-libxml-prefix="${LIBXML}/_build_macos" --prefix="${$(pwd)}/_build_macos"

make -s -j install

# Copy the header and library files.

cp -R _build_macos/include/libxslt "${OUTPUT}/Headers"
cp _build_macos/lib/libxslt.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libexslt.a "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

# Return to source/macOS directory

#================

cd "${START}"

