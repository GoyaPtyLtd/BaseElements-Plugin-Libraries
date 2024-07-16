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

rm -f Libraries/macOS/libfontconfig.a

rm -rf Headers/fontconfig
mkdir Headers/fontconfig

# Switch to our build directory

cd ../source/${PLATFORM}

export LIBEXPAT=`pwd`'/libexpat/_build'

rm -rf fontconfig
mkdir fontconfig
tar -xf ../fontconfig.tar.gz -C fontconfig --strip-components=1
cd fontconfig

mkdir _build
export PREFIX=`pwd`'/_build'

# Build macOS

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}" \
	FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/${PLATFORM} -lfreetype" \
	./configure --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
	--with-expat=${LIBEXPAT} \
	--prefix="${PREFIX}" 

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}" \
	FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/${PLATFORM} -lfreetype" \
	./configure --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
	--with-expat=${LIBEXPAT} \
	--prefix="${PREFIX}" 

fi

make -j install

# Copy the header and library files.

cp -R _build/include/fontconfig/* "${OUTPUT}/Headers/fontconfig"
cp _build/lib/libfontconfig.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
