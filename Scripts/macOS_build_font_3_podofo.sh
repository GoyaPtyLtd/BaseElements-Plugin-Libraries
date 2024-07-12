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
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/${PLATFORM}/libpodofo.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/podofo
	mkdir Headers/podofo
fi

# Switch to our build directory

cd ../source/${PLATFORM}

export LIBUNISTRING=`pwd`'/libunistring/_build'

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



cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
		 -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE -DPODOFO_BUILD_SHARED:BOOL=FALSE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/macOS/libfreetype.a" -DFREETYPE_INCLUDE_DIR="${OUTPUT}/Headers/freetype2" \
		 -DFONTCONFIG_LIBRARIES="${OUTPUT}/Libraries/macOS/fontconfig.a" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DOPENSSL_LIBRARIES="${OUTPUT}/Libraries/macOS/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DLIBCRYPTO_LIBRARIES="${OUTPUT}/Libraries/macOS/libcrypto.a" -DLIBCRYPTO_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DUNISTRING_LIBRARY="${OUTPUT}/Libraries/macOS/libunistring.a" -DUNISTRING_INCLUDE_DIR="${OUTPUT}/Headers/libunistring" \
		 -DZLIB_LIBRARY_RELEASE="${OUTPUT}/Libraries/macOS/libz.a" -DZLIB_INCLUDE_DIR="${OUTPUT}/Headers/zlib" \
		 -DLIBJPEG_LIBRARY_RELEASE="${OUTPUT}/Libraries/macOS/libjpeg.a" -DLIBJPEG_INCLUDE_DIR="${OUTPUT}/Headers/libturbojpeg" \
		 -DPNG_LIBRARY="${OUTPUT}/Libraries/macOS/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT}/Headers/libpng" \
		 -DCMAKE_CXX_STANDARD=11 \
		 -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=11.0 -stdlib=libc++" \
		 -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=11.0 -stdlib=libc++" .

make -j install

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build/include/podofo/* "${OUTPUT}/Headers/podofo"
fi

cp _build/lib/libpodofo.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}
