#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libpodofo.a

# Switch to our build directory

cd ../source/linux
rm -rf podofo
mkdir podofo
tar -xf ../podofo.tar.gz -C podofo --strip-components=1
cd podofo

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
		 -DPODOFO_BUILD_LIB_ONLY:BOOL=TRUE -DPODOFO_BUILD_STATIC:BOOL=TRUE \
         -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/linux/libfreetype.a" -DFREETYPE_INCLUDE_DIRS="${OUTPUT}/Headers/freetype2" \
		 -DWANT_FONTCONFIG:BOOL=TRUE \
		 -DFontconfig_LIBRARY="${OUTPUT}/Libraries/linux/fontconfig.a" -DFontconfig_INCLUDE_DIR="${OUTPUT}/Headers" \
		 -DOPENSSL_CRYPTO_LIBRARY="${OUTPUT}/Libraries/linux/libcrypto.a" \
		 -DOPENSSL_SSL_LIBRARY="${OUTPUT}/Libraries/linux/libssl.a" -DOPENSSL_INCLUDE_DIR="${OUTPUT}/Headers/openssl" \
		 -DLIBXML2_LIBRARY="${OUTPUT}/Libraries/linux/libxml2.a" -DLIBXML2_INCLUDE_DIR="${OUTPUT}/Headers/libxml" \
		 -DLIBXML2_XMLLINT_EXECUTABLE="${SRCROOT}/linux/libxml/_build_linux/bin/xmllint" \
		 -DJPEG_LIBRARY="${OUTPUT}/Libraries/linux/libjpeg.a" -DJPEG_INCLUDE_DIR="${OUTPUT}/Headers/libturbojpeg" \
		 -DPNG_LIBRARY="${OUTPUT}/Libraries/linux/libpng16.a" -DPNG_PNG_INCLUDE_DIR="${OUTPUT}/Headers/libpng" \
		 -DWANT_LIB64:BOOL=TRUE \
		 -DCMAKE_CXX_FLAGS="-fPIC" .

make -j install

# Copy the library files.

cp _build_linux/lib/libpodofo.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}
