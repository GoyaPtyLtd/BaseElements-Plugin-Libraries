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
export LIBSSH=`pwd`'/libssh/_build'
export NGHTTP2=`pwd`'/nghttp2/_build'

export OPENSSL=`pwd`'/openssl/_build'
export OPENSSL_x86=`pwd`'/openssl/_build_x86_64'
export OPENSSL_arm=`pwd`'/openssl/_build_arm64'

rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl

mkdir _build
mkdir _build/lib
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	mkdir _build_x86_64
	export PREFIX_x86_64=`pwd`'/_build_x86_64'

	CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/openssl" \
	LDFLAGS="-L${OUTPUT}/Libraries/macOS" LIBS="-ldl" \
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2  \
	--with-zlib=${ZLIB} --with-openssl=${OPENSSL_x86} --with-libssh2=${LIBSSH} --with-nghttp2=${NGHTTP2} \
	--prefix="${PREFIX_x86_64}" \
	--host=x86_64-apple-darwin 

	make -j$(($(sysctl -n hw.ncpu) + 1))
	make install
	make -s -j distclean
	
	mkdir _build_arm64
	export PREFIX_arm64=`pwd`'/_build_arm64'

	CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/openssl" \
	LDFLAGS="-L${OUTPUT}/Libraries/macOS" LIBS="-ldl" \
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2  \
	--with-zlib=${ZLIB} --with-openssl=${OPENSSL_arm} --with-libssh2=${LIBSSH} --with-nghttp2=${NGHTTP2} \
	--prefix="${PREFIX_arm64}" \
	--host=x86_64-apple-darwin 

	make -j$(($(sysctl -n hw.ncpu) + 1))
	make install
	make -s -j distclean
	
	lipo -create "${PREFIX_x86_64}/lib/libcurl.a" "${PREFIX_arm64}/lib/libcurl.a" -output "${PREFIX}/lib/libcurl.a"

	# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others
	# TODO also investigate libidn which is also in podofo
	
elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then
	
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 \
	--with-zlib=${ZLIB} --with-openssl=${OPENSSL} --with-libssh2=${LIBSSH} \
	--prefix="${PREFIX}"

	make -j$(($(nproc) + 1))
	make install

fi


# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build_x86_64/include/* "${OUTPUT}/Headers/curl"
else
	cp -R _build/include/curl/* "${OUTPUT}/Headers/curl"
fi

cp _build/lib/libcurl.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}

