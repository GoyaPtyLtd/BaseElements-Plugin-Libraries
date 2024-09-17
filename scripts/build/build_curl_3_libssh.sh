#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1              # Number of parallel jobs
if [[ $OS = 'Darwin' ]]; then
	PLATFORM='macOS'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
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

rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C libssh --strip-components=1
cd libssh

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/zlib -I${OUTPUT}/Headers/openssl" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}/" LIBS="-ldl" \
	./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
	--with-libz --with-libz-prefix=${LIBZ} \
	--with-crypto=openssl \
	--host=x86_64-apple-darwin \
	--prefix="${PREFIX}"
	
elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS=-fPIC \
	CPPFLAGS="-I${OUTPUT}/Headers -I${OUTPUT}/Headers/zlib" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}" LIBS="-ldl" \
	./configure --disable-shared --enable-static --disable-examples-build --disable-dependency-tracking \
	--with-libz --with-libz-prefix=${LIBZ} \
	--with-crypto=openssl --with-libssl-prefix=${OPENSSL} \
	--prefix="${PREFIX}"

fi

make -j$(($(nproc) + 1))
make install


# Copy the header and library files.

cp -R _build/include/* "${OUTPUT}/Headers/libssh2"

cp _build/lib/libssh2.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
