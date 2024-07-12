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

cd ..
export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libfontconfig.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/fontconfig
	mkdir Headers/fontconfig
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf fontconfig
mkdir fontconfig
tar -xf ../fontconfig.tar.gz -C fontconfig --strip-components=1
cd fontconfig

mkdir _build
export PREFIX=`pwd`'/_build'

# Build macOS

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/${PLATFORM} -lfreetype" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}"
	./configure --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
	--prefix="${PREFIX}" \

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	LDFLAGS="-L${OUTPUT}/Libraries/linux" --with-expat=/usr/lib64/libexpat.so.1
	FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/${PLATFORM} -lfreetype" \
	 ./configure --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
	--prefix="${PREFIX}" \

fi

make -j install

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build/include/fontconfig/* "${OUTPUT}/Headers/fontconfig"
fi

cp _build/lib/libfontconfig.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
