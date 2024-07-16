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

rm -f Libraries/${PLATFORM}/libjq.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/jq
	mkdir Headers/jq
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf jq
mkdir jq
tar -xf ../jq.tar.gz  -C jq --strip-components=1
cd jq

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared \
	--enable-all-static --enable-pthread-tls --without-oniguruma \
	--prefix="${PREFIX}"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared \
	--enable-all-static --enable-pthread-tls --without-oniguruma \
	--prefix="${PREFIX}"

fi

make -j install

# Copy the header and library files.

# jq seems to require the version.h file, but doesn't put it into the prefix.
cp src/version.h "${OUTPUT}/Headers/jq"
cp -R _build/include/* "${OUTPUT}/Headers/jq"

cp _build/lib/libjq.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
