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

rm -f Libraries/${PLATFORM}/libheif.a

rm -rf Headers/libheif
mkdir Headers/libheif

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libheif
mkdir libheif
tar -xf ../libheif.tar.gz  -C libheif --strip-components=1
cd libheif

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=RELEASE \
	-DBUILD_SHARED_LIBS:BOOL=OFF -DWITH_REDUCED_VISIBILITY=OFF -DWITH_UNCOMPRESSED_CODEC=OFF \
	-DWITH_AOM_DECODER:BOOL=OFF -DWITH_AOM_ENCODER:BOOL=OFF \
	-DWITH_X265:BOOL=OFF -DWITH_LIBSHARPYUV:BOOL=OFF \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DZLIB_INCLUDE_DIR="${OUTPUT}/Headers/zlib/" -DZLIB_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libz.a" \
	-DLIBDE265_INCLUDE_DIR="${OUTPUT}/Headers/" -DLIBDE265_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libde265.a" \
	-DJPEG_INCLUDE_DIR="${OUTPUT}/Headers/libturbojpeg/" -DJPEG_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libjpeg.a" ./

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then
	
	CFLAGS="-fPIC" \
	cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=RELEASE \
	-DBUILD_SHARED_LIBS:BOOL=OFF -DWITH_REDUCED_VISIBILITY=OFF -DWITH_UNCOMPRESSED_CODEC=OFF \
	-DWITH_AOM_DECODER:BOOL=OFF -DWITH_AOM_ENCODER:BOOL=OFF \
	-DWITH_X265:BOOL=OFF -DWITH_LIBSHARPYUV:BOOL=OFF \
	-DZLIB_INCLUDE_DIR="${OUTPUT}/Headers/zlib/" -DZLIB_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libz.a" \
	-DLIBDE265_INCLUDE_DIR="${OUTPUT}/Headers/" -DLIBDE265_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libde265.a" \
	-DJPEG_INCLUDE_DIR="${OUTPUT}/Headers/libturbojpeg/" -DJPEG_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libjpeg.a" ./

	make -j$(($(nproc) + 1))
fi

make install

# Copy the header and library files.

cp -R _build/include/libheif/* "${OUTPUT}/Headers/libheif"
cp _build/lib/libheif.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
