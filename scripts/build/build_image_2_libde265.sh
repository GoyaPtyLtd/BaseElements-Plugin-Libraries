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


SRCROOT=$(pwd)
cd ../../Output
OUTPUT=$(pwd)

# Remove old libraries and Headers

rm -f Libraries/${PLATFORM}/libde265.a

rm -rf Headers/libde265
mkdir Headers/libde265

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libde265
mkdir libde265
tar -xf ../libde265.tar.gz  -C libde265 --strip-components=1
cd libde265

mkdir _build
PREFIX=$(pwd)'/_build'

# Build

if [[ $PLATFORM = 'macOS' ]]; then

	cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_OSX_DEPLOYMENT_TARGET="10.15" \
	-DBUILD_SHARED_LIBS=OFF -DENABLE_SDL=FALSE -DENABLE_DECODER=OFF ./

elif [[ $OS = 'Linux' ]]; then

  CC=clang CXX=clang++ \
	cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DBUILD_SHARED_LIBS=OFF -DENABLE_SDL=FALSEG -DENABLE_DECODER=OFF ./

	#./configure --prefix="${PREFIX}" --disable-shared --enable-static --disable-dec265 --disable-sherlock265 --disable-sse --disable-dependency-tracking

fi

make -j${JOBS}
make install

# Copy the header and library files.

cp -R _build/include/libde265/* "${OUTPUT}/Headers/libde265"
cp _build/lib/libde265.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd "${SRCROOT}"
