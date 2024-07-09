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
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libboost_atomic.a
rm -f Libraries/${PLATFORM}/libboost_date_time.a
rm -f Libraries/${PLATFORM}/libboost_filesystem.a
rm -f Libraries/${PLATFORM}/libboost_program_options.a
rm -f Libraries/${PLATFORM}/libboost_regex.a
rm -f Libraries/${PLATFORM}/libboost_thread.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/boost
	mkdir Headers/boost
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf boost
mkdir boost
tar -xf ../boost.tar.gz -C boost --strip-components=1
cd boost

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

./bootstrap.sh

if [ ${PLATFORM} = 'macOS' ]; then

	./b2 toolset=clang cxxflags="-arch arm64 -arch x86_64" \
	address-model=64 link=static runtime-link=static install \
	--prefix="${PREFIX}" \
	--with-program_options --with-regex --with-date_time --with-filesystem --with-thread \
	cxxflags="-mmacosx-version-min=10.15 -stdlib=libc++" linkflags="-stdlib=libc++"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	./b2 cflags=-fPIC cxxflags=-fPIC \
	address-model=64 link=static runtime-link=static install \
	--prefix="${PREFIX}" \
	--with-program_options --with-regex --with-date_time --with-filesystem --with-thread

fi

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build_macos/include/boost/* "${OUTPUT}/Headers/boost"
fi

cp _build/lib/libboost_atomic.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libboost_date_time.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libboost_filesystem.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libboost_program_options.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libboost_regex.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libboost_thread.a "${OUTPUT}/Libraries/${PLATFORM}"

#Build iOS

#./iOS_build_boost.sh  -ios --boost-version 1.75.0 --boost-libs "program_options regex date_time filesystem thread"

#cp -R dist/boost.xcframework "${OUTPUT}/Libraries/iOS"

# Return to source directory

cd ${SRCROOT}
