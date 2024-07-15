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

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libxml2.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/libxml
	mkdir Headers/libxml
fi

# Switch to our build directory

cd ../source/${PLATFORM}

export ICONV=`pwd`'/libiconv/_build'

rm -rf libxml
mkdir libxml
tar -xf ../libxml.tar.xz -C libxml --strip-components=1
cd libxml

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --with-threads --without-python --without-zlib --without-lzma \
	--with-iconv="${ICONV}" \
	--prefix="${PREFIX}"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS=-fPIC \
	./configure --disable-shared --with-threads --without-python --without-zlib --without-lzma \
	--prefix="${PREFIX}"

fi

make -j install

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	#This affects when you're compiling in XCode later - it will look for the system iconv, this makes it use our one.
	sed -i '' -e 's|#include <iconv/iconv\.h\>|#include <iconv\.h>|g' "${PREFIX}/include/libxml2/libxml/encoding.h"
	
	cp -R _build/include/libxml2/libxml/* "${OUTPUT}/Headers/libxml"
fi

cp _build/lib/libxml2.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
