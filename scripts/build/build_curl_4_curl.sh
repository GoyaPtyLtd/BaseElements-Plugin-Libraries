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

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/curl
	mkdir Headers/curl
fi

# Switch to our build directory

cd ../source/${PLATFORM}

export ZLIB=`pwd`'/zlib/_build'
export OPENSSL=`pwd`'/openssl/_build'
export LIBSSH=`pwd`'/libssh/_build'

export OPENSSL_x86=`pwd`'/openssl/_build_x86_64'
export OPENSSL_arm=`pwd`'/openssl/_build_arm64'
export LIBSSH_x86=`pwd`'/libssh/_build_x86_64'
export LIBSSH_arm=`pwd`'/libssh/_build_arm64'

rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	#curl supports a cross compile, but we built openssl in two stages and curl looks for the PKG_CONFIG_PATH and if we use that then we have to refer
	# to a single build of openssl and it will fail with missing platform issues
	# so it's simpler to do two builds of curl as well than try to figure out how the fuck to cross compile openssl

	mkdir _build_x86_64
	export PREFIX_x86_64=`pwd`'/_build_x86_64'

	CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no \
	--enable-mqtt --with-zlib=${ZLIB} \
	--with-openssl=${OPENSSL_x86} \
	--with-libssh2=${LIBSSH_x86} \
	--prefix="${PREFIX_x86_64}" \
	--host=x86_64-apple-darwin 

	make install
	make -s -j distclean

	mkdir _build_arm64
	export PREFIX_arm64=`pwd`'/_build_arm64'
	
	CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no \
	--enable-mqtt --with-zlib=${ZLIB} \
	--with-openssl=${OPENSSL_arm} \
	--with-libssh2=${LIBSSH_arm} \
	--prefix="${PREFIX_arm64}" \
	--host=x86_64-apple-darwin 

	make install
	make -s -j distclean

	mkdir ${PREFIX}/lib

	lipo -create "${PREFIX_x86_64}/lib/libcurl.a" "${PREFIX_arm64}/lib/libcurl.a" -output "${PREFIX}/lib/libcurl.a"

	# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others
	# TODO also investigate libidn which is also in podofo
	
elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then
	
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no \
	--enable-mqtt --with-zlib=${ZLIB} \
	--with-openssl=${OPENSSL} \
	--with-libssh2=${LIBSSH} \
	--prefix="${PREFIX}"

	make -j install

fi

# Copy the header and library files.

cp -R _build_x86_64/include/curl/* "${OUTPUT}/Headers/curl"
cp _build/lib/libcurl.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}

