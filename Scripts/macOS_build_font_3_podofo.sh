#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libpodofo.a
rm -rf Headers/podofo
mkdir Headers/podofo

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf podofo
mkdir podofo
tar -xf ../podofo.tar.gz -C podofo --strip-components=1
cd podofo

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`'/_build_macos'
export PREFIX_ios=`pwd`'/_build_ios'
export PREFIX_iosSimulator=`pwd`'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`'/_build_iosSimulatorx86'

# Build macOS

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DPODOFO_BUILD_STATIC:BOOL=TRUE \
         -DFREETYPE_INCLUDE_DIRS="${OUTPUT}/Headers/freetype2" \
		 -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/macOS/libfreetype.a" \
		 -DFontconfig_LIBRARY="${OUTPUT}/Libraries/macOS/fontconfig.a" -DFontconfig_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DOPENSSL_CRYPTO_LIBRARY="${OUTPUT}/Libraries/macOS/libcrypto.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT}/Headers/openssl" -DOPENSSL_SSL_LIBRARY="${OUTPUT}/Libraries/macOS/libssl.a" \
		 -DLIBXML2_LIBRARY="${OUTPUT}/Libraries/macOS/libxml2.a" -DLIBXML2_INCLUDE_DIRS="${OUTPUT}/Headers/libxml2" \
		 -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_CXX_STANDARD=11 \
		 -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" \
		 -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" ./
		 
make -j install

# Copy the header and library files.

cp -R _build_macos/include/podofo/* "${OUTPUT}/Headers/podofo"
cp _build_macos/lib/libpodofo.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
