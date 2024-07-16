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

rm -f Libraries/${PLATFORM}/libturbojpeg.a

rm -rf Headers/libturbojpeg
mkdir Headers/libturbojpeg

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
	
	mkdir _build_arm64
	export PREFIX_arm64=`pwd`'/_build_arm64'
	
	echo "set(CMAKE_SYSTEM_NAME Darwin)" > toolchain.cmake
	echo "set(CMAKE_SYSTEM_PROCESSOR aarch64)" >> toolchain.cmake
	
	CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	cmake --fresh -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
	-DCMAKE_INSTALL_PREFIX="${PREFIX_arm64}" ./

	make install

	mkdir _build_x86_64
	export PREFIX_x86_64=`pwd`'/_build_x86_64'
	
	echo "set(CMAKE_SYSTEM_NAME Darwin)" > toolchain.cmake
	echo "set(CMAKE_SYSTEM_PROCESSOR x86_64)" >> toolchain.cmake
	
	CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	cmake --fresh -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_SHARED=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
	-DCMAKE_INSTALL_PREFIX="${PREFIX_x86_64}"  ./
	
	make install

	mkdir -p ${PREFIX}/lib

	lipo -create "${PREFIX_x86_64}/lib/libturbojpeg.a" "${PREFIX_arm64}/lib/libturbojpeg.a" -output "${PREFIX}/lib/libturbojpeg.a"
	lipo -create "${PREFIX_x86_64}/lib/libjpeg.a" "${PREFIX_arm64}/lib/libjpeg.a" -output "${PREFIX}/lib/libjpeg.a"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_SHARED_LIBS=NO -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCMAKE_IGNORE_PATH=/usr/lib/x86_64-linux-gnu/ \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}"  ./

	make install

fi

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build_x86_64/include/libturbojpeg/* "${OUTPUT}/Headers/libturbojpeg"
else
	cp -R _build/include/libturbojpeg/* "${OUTPUT}/Headers/libturbojpeg"
fi

cp _build/lib/libturbojpeg.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libjpeg.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}
