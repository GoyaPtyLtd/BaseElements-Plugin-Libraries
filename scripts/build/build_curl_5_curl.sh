#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1              # Number of parallel jobs
if [[ $OS = 'Darwin' ]]; then
		PLATFORM='macOS'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
    if [[ $ARCH = 'aarch64' ]]; then
        HOST='x86_64-apple-darwin'
    elif [[ $ARCH = 'x86_64' ]]; then
        HOST='aarch64-apple-darwin'
    fi
elif [[ $OS = 'Linux' ]]; then
    JOBS=$(($(nproc) + 1))
    if [[ $ARCH = 'aarch64' ]]; then
        PLATFORM='linuxARM'
    elif [[ $ARCH = 'x86_64' ]]; then
        PLATFORM='linux'
    fi
fi
if [[ "${PLATFORM}X" = 'X' ]]; then     # $PLATFORM is empty
	echo "!! Unknown OS/ARCH: $OS/$ARCH"
	exit 1
fi


SRCROOT=${PWD}
cd ../../Output
OUTPUT=${PWD}

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libcurl.a

rm -rf Headers/curl
mkdir Headers/curl

# Switch to our build directory

cd ../source/${PLATFORM}

ZLIB=${PWD}'/zlib/_build'
LIBSSH=${PWD}'/libssh/_build'
NGHTTP2=${PWD}'/nghttp2/_build'

OPENSSL=${PWD}'/openssl/_build'
OPENSSL_x86=${PWD}'/openssl/_build_x86_64'
OPENSSL_arm=${PWD}'/openssl/_build_arm64'

rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl

mkdir _build
mkdir _build/lib
PREFIX=${PWD}'/_build'

# Build

if [[ $PLATFORM = 'macOS' ]]; then

	mkdir _build_x86_64
	PREFIX_x86_64=${PWD}'/_build_x86_64'

	CFLAGS="-arch x86_64 -mmacosx-version-min=10.15" \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/openssl" \
	LDFLAGS="-L${OUTPUT}/Libraries/macOS" LIBS="-ldl" \
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2  \
	--with-zlib=${ZLIB} --with-openssl=${OPENSSL_x86} --with-libssh2=${LIBSSH} --with-nghttp2=${NGHTTP2} \
	--prefix="${PREFIX_x86_64}" \
	--host="${HOST}"

	make -j${JOBS}
	make install
	make -s distclean

	mkdir _build_arm64
	PREFIX_arm64=${PWD}'/_build_arm64'

	CFLAGS="-arch arm64 -mmacosx-version-min=10.15" \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/openssl" \
	LDFLAGS="-L${OUTPUT}/Libraries/macOS" LIBS="-ldl" \
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2  \
	--with-zlib=${ZLIB} --with-openssl=${OPENSSL_arm} --with-libssh2=${LIBSSH} --with-nghttp2=${NGHTTP2} \
	--prefix="${PREFIX_arm64}" \
	--host="${HOST}"

	make -j${JOBS}
	make install
	make -s distclean

	lipo -create "${PREFIX_x86_64}/lib/libcurl.a" "${PREFIX_arm64}/lib/libcurl.a" -output "${PREFIX}/lib/libcurl.a"

	# TODO this had  --without-libpsl --without-brotli --without-zstd added to it for compatibility with latest curl.  It would be good to at least add the libpsl but I don't know about the others
	# TODO also investigate libidn which is also in podofo

elif [[ $OS = 'Linux' ]]; then

  CC=clang CXX=clang++ \
	./configure --disable-dependency-tracking --enable-static --disable-shared --disable-manual \
	--without-libpsl --without-brotli --without-zstd --enable-ldap=no --without-libidn2 \
	--with-zlib=${ZLIB} --with-openssl=${OPENSSL} --with-libssh2=${LIBSSH} \
	--prefix="${PREFIX}"

	make -j${JOBS}
	make install

fi


# Copy the header and library files.

if [[ $PLATFORM = 'macOS' ]]; then
	cp -R _build_x86_64/include/* "${OUTPUT}/Headers/curl"
else
	cp -R _build/include/curl/* "${OUTPUT}/Headers/curl"
fi

cp _build/lib/libcurl.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd "${SRCROOT}"

