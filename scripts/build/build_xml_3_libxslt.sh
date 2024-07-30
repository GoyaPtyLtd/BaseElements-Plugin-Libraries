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

rm -f Libraries/${PLATFORM}/libxslt.a
rm -f Libraries/${PLATFORM}/libexslt.a

rm -rf Headers/libxslt
mkdir Headers/libxslt

# Switch to our build directory

cd ../source/${PLATFORM}

export LIBXML=`pwd`'/libxml/_build'

rm -rf libxslt
mkdir libxslt
tar -xf ../libxslt.tar.xz -C libxslt --strip-components=1
cd libxslt

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-shared --without-python --without-crypto \
	--with-libxml-prefix="${LIBXML}" \
	--prefix="${PREFIX}"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS=-fPIC \
	./configure --disable-shared --without-python --without-crypto \
	--with-libxml-prefix="${LIBXML}" \
	--prefix="${PREFIX}"

	make -j$(($(nproc) + 1))
fi

make install

# Copy the header and library files.

cp -R _build/include/libxslt/* "${OUTPUT}/Headers/libxslt"

cp _build/lib/libxslt.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libexslt.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}

