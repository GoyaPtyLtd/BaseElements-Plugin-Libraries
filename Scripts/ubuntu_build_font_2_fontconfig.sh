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

rm -f Libraries/macOS/libfontconfig.a

# Switch to our build directory

cd ../source/linux
rm -rf fontconfig
mkdir fontconfig
tar -xf ../fontconfig.tar.gz -C fontconfig --strip-components=1
cd fontconfig

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

CFLAGS="-fPIC" ./configure \
--disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
--prefix="${PREFIX}" \
FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="${OUTPUT}/Libraries/linux" \
LDFLAGS="-L${OUTPUT}/Libraries/linux" --with-expat=/usr/lib64/libexpat.so.1

make -j install

# Copy the header and library files.

cp _build_linux/lib/libfontconfig.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
