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

rm -f Libraries/${PLATFORM}/libopenjp2.a

rm -rf Headers/libopenjp2
mkdir Headers/libopenjp2

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libopenjp2
mkdir libopenjp2
tar -xf ../libopenjp2.tar.gz  -C libopenjp2 --strip-components=1
cd libopenjp2

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_SHARED_LIBS:BOOL=OFF \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCMAKE_LIBRARY_PATH:path="${OUTPUT}/Libraries/${PLATFORM}" -DCMAKE_INCLUDE_PATH:path="${OUTPUT}/Headers" \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" ./

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then
	
	CFLAGS="-fPIC" \
	cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_SHARED_LIBS:BOOL=OFF \
	-DCMAKE_IGNORE_PATH=/usr/lib/x86_64-linux-gnu/ \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCMAKE_LIBRARY_PATH:path="${OUTPUT}/Libraries/${PLATFORM}" -DCMAKE_INCLUDE_PATH:path="${OUTPUT}/Headers" \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" ./

	make -j$(($(nproc) + 1))

fi

make install

# Copy the header and library files.

cp -R _build/include/openjpeg-2.5/* "${OUTPUT}/Headers/libopenjp2"
cp _build/lib/libopenjp2.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
