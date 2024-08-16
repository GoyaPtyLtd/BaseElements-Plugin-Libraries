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

rm -f Libraries/${PLATFORM}/libcurl.a

rm -rf Headers/curl
mkdir Headers/curl

# Switch to our build directory

cd ../source/${PLATFORM}

export ZLIB=`pwd`'/zlib/_build'
export OPENSSL=`pwd`'/openssl/_build'
export LIBSSH=`pwd`'/libssh/_build'
export NGHTTP2=`pwd`'/nghttp2/_build'

export OPENSSL_x86=`pwd`'/openssl/_build_x86_64'
export OPENSSL_arm=`pwd`'/openssl/_build_arm64'

rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" \
	CPPFLAGS="-I${SRCROOT}/Headers -I${SRCROOT}/Headers/libssh2 -I${SRCROOT}/Headers/openssl" \
	LDFLAGS="-L${SRCROOT}/Libraries/macOS" LIBS="-ldl" \
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2  \
	--with-zlib=${ZLIB} --with-openssl=${OPENSSL} --with-libssh2=${LIBSSH} --with-nghttp2=${NGHTTP2} \
	--prefix="${PREFIX}" \
	--host=x86_64-apple-darwin 

	make -j$(($(sysctl -n hw.ncpu) + 1))

	# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others
	# TODO also investigate libidn which is also in podofo
	
elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then
	
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 \
	--with-zlib=${ZLIB} --with-openssl=${OPENSSL} --with-libssh2=${LIBSSH} \
	--prefix="${PREFIX}"

	make -j$(($(nproc) + 1))

fi

make install

# Copy the header and library files.

cp -R _build/include/curl/* "${OUTPUT}/Headers/curl"

cp _build/lib/libcurl.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}

