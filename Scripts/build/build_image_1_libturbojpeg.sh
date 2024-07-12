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

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libturbojpeg.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/libturbojpeg
	mkdir Headers/libturbojpeg
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf libturbojpeg
mkdir libturbojpeg
tar -xf ../libturbojpeg.tar.gz  -C libturbojpeg --strip-components=1
cd libturbojpeg

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}"  ./
	
elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_SHARED_LIBS=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCMAKE_IGNORE_PATH=/usr/lib/x86_64-linux-gnu/ \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}"  ./

fi

make install DESTDIR="${PREFIX}"

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build/opt/libjpeg-turbo/include/* "${OUTPUT}/Headers/libturbojpeg"
fi

cp _build/opt/libjpeg-turbo/lib/libturbojpeg.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/opt/libjpeg-turbo/lib/libjpeg.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}
