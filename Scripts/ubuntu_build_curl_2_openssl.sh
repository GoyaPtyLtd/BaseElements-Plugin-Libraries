#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/linux/libcrypto.a
rm -f Libraries/linux/libssl.a

# Switch to our build directory

cd ../source/linux
rm -rf openssl
mkdir openssl
tar -xf ../openssl.tar.gz -C openssl --strip-components=1
cd openssl

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

./Configure linux-generic64 no-engine no-hw no-shared --prefix="${PREFIX}"
make -j install

# Copy the header and library files.

cp _build_linux/libcrypto.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build_linux/libssl.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
