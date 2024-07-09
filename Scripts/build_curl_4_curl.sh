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

rm -f Libraries/${PLATFORM}/libcurl.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/curl
	mkdir Headers/curl
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	CPPFLAGS=" -I${SRCROOT}/Headers -I${SRCROOT}/Headers/libssh2 -I${SRCROOT}/Headers/openssl" \
	LDFLAGS=" -L${SRCROOT}/Libraries/${PLATFORM}" LIBS="-ldl" \
	./configure --disable-dependency-tracking --enable-static --disable-shared \
	--with-ssl --with-zlib --with-libssh2 --without-tests \
	--without-libpsl --without-brotli --without-zstd \
	--prefix="${PREFIX}" \
	--host=x86_64-apple-darwin 

	# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others
	# TODO also investigate libidn which is also in podofo
	
elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then
	
	CPPFLAGS=" -I${SRCROOT}/Headers  -I${SRCROOT}/Headers/libssh2 -I${SRCROOT}/Headers/openssl -I${SRCROOT}/Headers/zlib"  LDFLAGS="-L${SRCROOT}/Libraries/${PLATFORM}" LIBS="-ldl" \
	./configure --disable-dependency-tracking --enable-static --disable-shared \
	--with-ssl --with-zlib --with-libssh2 --without-tests \
	--prefix="${PREFIX}"

fi

make -j install

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build/include/curl/* "${OUTPUT}/Headers/curl"
fi

cp _build/lib/libcurl.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}

