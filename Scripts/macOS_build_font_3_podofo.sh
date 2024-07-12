#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libpodofo.a
rm -rf Headers/podofo
mkdir Headers/podofo

# Switch to our build directory

cd ../source/macOS

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

#		-DOPENSSL_CRYPTO_LIBRARY="${OUTPUT}/Libraries/macOS/libcrypto.a" \
#		-DOPENSSL_SSL_LIBRARY="${OUTPUT}/Libraries/macOS/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT}/Headers/openssl" \
#		-DLIBXML2_LIBRARY="${OUTPUT}/Libraries/macOS/libxml2.a" -DLIBXML2_INCLUDE_DIR="${OUTPUT}/Headers/libxml" \
#		-DLIBXML2_XMLLINT_EXECUTABLE="${SRCROOT}/macOS/libxml/_build_macos/bin/xmllint" \

# 	-DFONTCONFIG_INCLUDE_DIR="${SRCROOT}/Headers" -DFONTCONFIG_LIBRARY_RELEASE="${SRCROOT}/Libraries/macOS/libfontconfig.a" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.13 -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.13 -stdlib=libc++" -DCMAKE_CXX_STANDARD=11 -DCXX_STANDARD_REQUIRED=ON ./



cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
		 -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/macOS/libfreetype.a" -DFREETYPE_INCLUDE_DIR="${OUTPUT}/Headers/freetype2" \
		 -DFONTCONFIG_LIBRARIES="${OUTPUT}/Libraries/macOS/fontconfig.a" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DLIBCRYPTO_LIBRARIES="${OUTPUT}/Libraries/macOS/libcrypto.a" -DLIBCRYPTO_INCLUDE_DIR="${OUTPUT}/Headers/openssl" \
		 -DZLIB_LIBRARIES="${OUTPUT}/Libraries/macOS/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT}/Headers/zlib" \
		 -DLIBJPEG_LIBRARY_RELEASE="${OUTPUT}/Libraries/macOS/libjpeg.a" -DLIBJPEG_INCLUDE_DIR="${OUTPUT}/Headers/libturbojpeg" \
		 -DPNG_LIBRARY="${OUTPUT}/Libraries/macOS/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT}/Headers/libpng" \
		 -DCMAKE_CXX_STANDARD=11 \
		 -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
		 -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" .

make -j install

# Copy the header and library files.

cp -R _build_macos/include/podofo/* "${OUTPUT}/Headers/podofo"
cp _build_macos/lib/libpodofo.a "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
