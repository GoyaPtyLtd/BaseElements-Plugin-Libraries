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

rm -f Libraries/linux/libde265.a

# Switch to our build directory

cd ../source/linux
rm -rf libde265
mkdir libde265
tar -xf ../libde265.tar.gz  -C libde265 --strip-components=1
cd libde265

mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

autoupdate
autoreconf -fi
./autogen.sh
./configure --prefix="${PREFIX}" --disable-shared --enable-static --disable-dec265 --disable-sherlock265 --disable-sse --disable-dependency-tracking
make -j install

# Copy the header and library files.

cp _build_linux/lib/libde265.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}
