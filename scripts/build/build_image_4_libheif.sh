#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1              # Number of parallel jobs
if [[ $OS = 'Darwin' ]]; then
		PLATFORM='macOS'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
elif [[ $OS = 'Linux' ]]; then
    JOBS=$(($(nproc) + 1))
    if [[ $ARCH = 'aarch64' ]]; then
        PLATFORM='linuxARM'
    elif [[ $ARCH = 'x86_64' ]]; then
        PLATFORM='linux'
    fi
fi
if [[ "${PLATFORM}X" = 'X' ]]; then     # $PLATFORM is empty
	echo "!! Unknown OS/ARCH: $OS/$ARCH"
	exit 1
fi


SRCROOT=${PWD}
cd ../../Output
OUTPUT=${PWD}

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
PREFIX=${PWD}'/_build'

# Build

if [[ $PLATFORM = 'macOS' ]]; then

	export MACOSX_DEPLOYMENT_TARGET=10.15

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	cmake -G "Unix Makefiles" --preset=release-noplugins -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=RELEASE \
	-DBUILD_SHARED_LIBS:BOOL=OFF -DWITH_REDUCED_VISIBILITY=OFF -DWITH_UNCOMPRESSED_CODEC=OFF \
	-DWITH_AOM_DECODER:BOOL=OFF -DWITH_AOM_ENCODER:BOOL=OFF \
	-DWITH_X265:BOOL=OFF -DWITH_LIBSHARPYUV:BOOL=OFF \
	-DZLIB_INCLUDE_DIR="${OUTPUT}/Headers/zlib/" -DZLIB_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libz.a" \
	-DLIBDE265_INCLUDE_DIR="${OUTPUT}/Headers/" -DLIBDE265_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libde265.a" \
	-DJPEG_INCLUDE_DIR="${OUTPUT}/Headers/libturbojpeg/" -DJPEG_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libjpeg.a" ./

elif [[ $OS = 'Linux' ]]; then

  	CC=clang CXX=clang++ CFLAGS="-fPIC" \
	cmake -G "Unix Makefiles" --preset=release-noplugins -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=RELEASE \
	-DBUILD_SHARED_LIBS:BOOL=OFF -DWITH_REDUCED_VISIBILITY=OFF -DWITH_UNCOMPRESSED_CODEC=OFF \
	-DWITH_AOM_DECODER:BOOL=OFF -DWITH_AOM_ENCODER:BOOL=OFF \
	-DWITH_X265:BOOL=OFF -DWITH_LIBSHARPYUV:BOOL=OFF \
	-DZLIB_INCLUDE_DIR="${OUTPUT}/Headers/zlib/" -DZLIB_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libz.a" \
	-DLIBDE265_INCLUDE_DIR="${OUTPUT}/Headers/" -DLIBDE265_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libde265.a" \
	-DJPEG_INCLUDE_DIR="${OUTPUT}/Headers/libturbojpeg/" -DJPEG_LIBRARY="${OUTPUT}/Libraries/${PLATFORM}/libjpeg.a" ./

fi

make -j${JOBS}
make install

# Copy the header and library files.

cp -R _build/include/libheif/* "${OUTPUT}/Headers/libheif"
cp _build/lib/libheif.a "${OUTPUT}/Libraries/${PLATFORM}"

cd "${SRCROOT}"
