#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname) = 'Darwin' ]; then
	export PLATFORM='macOS'
elif [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/${PLATFORM}/libpodofo.a

rm -rf Headers/podofo
mkdir Headers/podofo

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf podofo
mkdir podofo
tar -xf ../podofo.tar.gz -C podofo --strip-components=1
cd podofo

mkdir _build
export PREFIX=`pwd`'/_build'

# Build macOS

#		-DOPENSSL_CRYPTO_LIBRARY="${OUTPUT}/Libraries/macOS/libcrypto.a" \
#		-DOPENSSL_SSL_LIBRARY="${OUTPUT}/Libraries/macOS/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT}/Headers/openssl" \
#		-DLIBXML2_LIBRARY="${OUTPUT}/Libraries/macOS/libxml2.a" -DLIBXML2_INCLUDE_DIR="${OUTPUT}/Headers/libxml" \
#		-DLIBXML2_XMLLINT_EXECUTABLE="${SRCROOT}/macOS/libxml/_build_macos/bin/xmllint" \

# 	-DFONTCONFIG_INCLUDE_DIR="${SRCROOT}/Headers" -DFONTCONFIG_LIBRARY_RELEASE="${SRCROOT}/Libraries/macOS/libfontconfig.a" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.13 -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.13 -stdlib=libc++" -DCMAKE_CXX_STANDARD=11 -DCXX_STANDARD_REQUIRED=ON ./

if [ ${PLATFORM} = 'macOS' ]; then

	cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
		 -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE -DPODOFO_BUILD_SHARED:BOOL=FALSE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/${PLATFORM}/libfreetype.a" -DFREETYPE_INCLUDE_DIR="${OUTPUT}/Headers/freetype2" \
		 -DWANT_FONTCONFIG:BOOL=TRUE \
		 -DFONTCONFIG_LIBRARIES="${OUTPUT}/Libraries/${PLATFORM}/fontconfig.a" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DOPENSSL_LIBRARIES="${OUTPUT}/Libraries/${PLATFORM}/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DLIBCRYPTO_LIBRARIES="${OUTPUT}/Libraries/${PLATFORM}/libcrypto.a" -DLIBCRYPTO_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DLIBXML2_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libxml2.a" -DLIBXML2_INCLUDE_DIR="${OUTPUT}/Headers/libxml" \
		 -DLIBXML2_XMLLINT_EXECUTABLE="${SRCROOT}/Output/${PLATFORM}/libxml/_build/bin/xmllint" \
		 -DUNISTRING_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libunistring.a" -DUNISTRING_INCLUDE_DIR="${OUTPUT}/Headers/libunistring" \
		 -DZLIB_LIBRARY_RELEASE="${OUTPUT}/Libraries/${PLATFORM}/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT}/Headers/zlib" \
		 -DLIBJPEG_LIBRARY_RELEASE="${OUTPUT}/Libraries/${PLATFORM}/libjpeg.a" -DLIBJPEG_INCLUDE_DIR="${OUTPUT}/Headers/libturbojpeg" \
		 -DPNG_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT}/Headers/libpng" \
		 -DCMAKE_CXX_STANDARD=11 \
		 -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=11.0 -stdlib=libc++" \
		 -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=11.0 -stdlib=libc++" .

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
		 -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/${PLATFORM}/libfreetype.a" -DFREETYPE_INCLUDE_DIR="${OUTPUT}/Headers/freetype2" \
		 -DWANT_FONTCONFIG:BOOL=TRUE \
		 -DFONTCONFIG_LIBRARIES="${OUTPUT}/Libraries/${PLATFORM}/fontconfig.a" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DLIBCRYPTO_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libcrypto.a" -DLIBCRYPTO_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DOPENSSL_LIBRARIES="${OUTPUT}/Libraries/${PLATFORM}/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DUNISTRING_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libunistring.a" -DUNISTRING_INCLUDE_DIR="${OUTPUT}/Headers/libunistring" \
		 -DZLIB_LIBRARY_RELEASE="${OUTPUT}/Libraries/${PLATFORM}/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT}/Headers/zlib" \
		 -DLIBJPEG_LIBRARY_RELEASE="${OUTPUT}/Libraries/${PLATFORM}/libjpeg.a" -DLIBJPEG_INCLUDE_DIR="${OUTPUT}/Headers/libturbojpeg" \
		 -DPNG_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT}/Headers/libpng" \
		 -DWANT_LIB64:BOOL=TRUE \
		 -DCMAKE_CXX_FLAGS="-fPIC" .

fi

make -j install

# Copy the header and library files.

cp -R _build/include/podofo/* "${OUTPUT}/Headers/podofo"
if [ ${PLATFORM} = 'macOS' ]; then
	cp _build/lib/libpodofo.a "${OUTPUT}/Libraries/${PLATFORM}"
else
	cp _build/lib64/libpodofo.a "${OUTPUT}/Libraries/${PLATFORM}"
fi

# Return to source directory

cd ${SRCROOT}
