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

rm -f Libraries/${PLATFORM}/libssh2.a

rm -rf Headers/libssh2
mkdir Headers/libssh2

# Switch to our build directory

cd ../source/${PLATFORM}

export LIBZ=`pwd`'/zlib/_build'
export OPENSSL=`pwd`'/openssl/_build'
export OPENSSL_x86=`pwd`'/openssl/_build_x86_64'
export OPENSSL_arm=`pwd`'/openssl/_build_arm64'

rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C libssh --strip-components=1
cd libssh

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	#libssh supports a cross compile, but we built openssl in two stages and curl looks for the PKG_CONFIG_PATH and if we use that then we have to refer
	# to a single build of openssl and it will fail with missing platform issues
	# so it's simpler to do two builds of libssh as well than try to figure out how the fuck to cross compile openssl

	mkdir _build_x86_64
	export PREFIX_x86_64=`pwd`'/_build_x86_64'

	CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/zlib" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" LIBS="-ldl" \
	./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
	--with-libz --with-libz-prefix=${LIBZ} \
	--with-crypto=openssl --with-libssl-prefix=${OPENSSL_x86} \
	--host=x86_64-apple-darwin \
	--prefix="${PREFIX_x86_64}"
	
	make install
	make -s -j distclean
	
	mkdir _build_arm64
	export PREFIX_arm64=`pwd`'/_build_arm64'
	
	CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/zlib" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" LIBS="-ldl" \
	./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
	--with-libz --with-libz-prefix=${LIBZ} \
	--with-crypto=openssl --with-libssl-prefix=${OPENSSL_arm} \
	--host=x86_64-apple-darwin \
	--prefix="${PREFIX_arm64}"

	make install
	make -s -j distclean
	
	mkdir ${PREFIX}/lib
	
	lipo -create "${PREFIX_x86_64}/lib/libssh2.a" "${PREFIX_arm64}/lib/libssh2.a" -output "${PREFIX}/lib/libssh2.a"

	
elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS=-fPIC \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/zlib" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}" LIBS="-ldl" \
	./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
	--with-libz --with-libz-prefix=${LIBZ} \
	--with-crypto=openssl --with-libssl-prefix=${OPENSSL} \
	--prefix="${PREFIX}"

	make -j$(($(nproc) + 1))
	make install

fi

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build_x86_64/include/* "${OUTPUT}/Headers/libssh2"
else
	cp -R _build/include/* "${OUTPUT}/Headers/libssh2"
fi

cp _build/lib/libssh2.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
