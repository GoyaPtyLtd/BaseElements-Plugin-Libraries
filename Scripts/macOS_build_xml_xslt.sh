#!/bin/bash -E

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
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'
export PREFIX_ios=`pwd`+'/_build_ios'
export PREFIX_iosSimulator=`pwd`+'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'/_build_iosSimulatorx86'

export ICONV=`pwd`

# Build macOS

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --prefix="${PREFIX}"

make install

# Copy the header and library files.

mkdir "${OUTPUT}/Headers/iconv"

cp -R "${PREFIX}/include/*.h" "${OUTPUT}/Headers/iconv"

cp "${PREFIX}/lib/libiconv.a" "${OUTPUT}/Libraries/macOS"
cp "${PREFIX}/lib/libcharset.a" "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====libxml2====

# Switch to our build directory

rm -rf libxml
mkdir libxml
tar -xf ../libxml.tar.gz -C libxml --strip-components=1
cd libxml

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'
export PREFIX_ios=`pwd`+'/_build_ios'
export PREFIX_iosSimulator=`pwd`+'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'/_build_iosSimulatorx86'
export LIBXML=`pwd`

# Build macOS

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./autogen.sh --disable-shared --with-threads --without-python --without-zlib --without-lzma --with-iconv=${ICONV}/_build_macos --prefix="${PREFIX}"

make -s -j install

#Need to change this so it finds my installed version and not the SDK supplied one.

sed -i '' -e 's|#include <iconv\.h\>|#include <iconv/iconv.h>|g' "${PREFIX}/include/libxml2/libxml/encoding.h"

# Copy the header and library files.

cp -R "${PREFIX}/include/libxml2/libxml" "${OUTPUT}/Headers"
cp "${PREFIX}/lib/libxml2.a" "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====libxslt====

# Switch to our build directory

rm -rf libxslt
mkdir libxslt
tar -xf ../libxslt.tar.gz -C libxslt --strip-components=1
cd libxslt

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'
export PREFIX_ios=`pwd`+'/_build_ios'
export PREFIX_iosSimulator=`pwd`+'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'/_build_iosSimulatorx86'

# Build macOS

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./autogen.sh --disable-shared --without-python --without-crypto --with-libxml-prefix="${LIBXML}/_build_macos" --prefix="${PREFIX}"

make -s -j install

# Copy the header and library files.

cp -R "${PREFIX}/include/libxslt" "${OUTPUT}/Headers"
cp "${PREFIX}/lib/libxslt.a" "${OUTPUT}/Libraries/macOS"
cp "${PREFIX}/lib/libexslt.a" "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

# Return to source directory

cd ${SRCROOT}

