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

# Remove old libraries and Headers

rm -f Libraries/${PLATFORM}/libde265.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/libde265
	mkdir Headers/libde265
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libde265
mkdir libde265
tar -xf ../libde265.tar.gz  -C libde265 --strip-components=1
cd libde265

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_OSX_DEPLOYMENT_TARGET="10.15" \
	-DBUILD_SHARED_LIBS=OFF -DENABLE_SDL=FALSE -DENABLE_DECODER=OFF ./

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DBUILD_SHARED_LIBS=OFF -DENABLE_SDL=FALSEG -DENABLE_DECODER=OFF ./

	#./configure --prefix="${PREFIX}" --disable-shared --enable-static --disable-dec265 --disable-sherlock265 --disable-sse --disable-dependency-tracking

fi

make -j install

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build/include/libde265/* "${OUTPUT}/Headers/libde265"
fi

cp _build/lib/libde265.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}
