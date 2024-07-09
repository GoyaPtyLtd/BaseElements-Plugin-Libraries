#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/linux/libcrypto.a
rm -f Libraries/linux/libssl.a

rm -f Libraries/linux/libssh2.a

rm -f Libraries/linux/libcurl.a

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

#====zlib====

# Switch to our build directory

rm -rf zlib
mkdir zlib
tar -xf ../zlib.tar.gz -C openssl --strip-components=1
cd zlib
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

CFLAGS="-fPIC" ./configure --static --prefix="${PREFIX}"
make -j install

# Copy the library files.

cp _build_linux/lib/libz.a "${OUTPUT}/Libraries/linux"

cd ${SRCROOT}

#====openssl====

# Switch to our build directory

rm -rf openssl
mkdir openssl
tar -xf ../openssl.tar.gz -C openssl --strip-components=1
cd openssl
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

./Configure linux-generic64 no-engine no-hw no-shared --prefix="${PREFIX}"
make -j install

# Copy the library files.

cp _build_linux/libcrypto.a "${OUTPUT}/Libraries/linux"
cp _build_linux/libssl.a "${OUTPUT}/Libraries/linux"

cd ${SRCROOT}

#====libssh2====

# Switch to our build directory

rm -rf libssh
mkdir libssh
tar -xf ../libssh.tar.gz -C libssh --strip-components=1
cd libssh
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

CFLAGS="-fPIC -I${SRCROOT}/Headers -I${SRCROOT}/Headers/zlib" LDFLAGS="-L${SRCROOT}/Libraries/linux/" LIBS="-ldl" ./configure --disable-shared --disable-examples-build --prefix="${PREFIX}"
make -j install

# Copy the library files.

cp _build_linux/lib/libssh2.a "${OUTPUT}/Libraries/linux"

cd ${SRCROOT}

#====curl====

# Switch to our build directory

rm -rf curl
mkdir curl
tar -xf ../curl.tar.gz -C curl --strip-components=1
cd curl
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

CPPFLAGS="-I${SRCROOT}/Headers -I${SRCROOT}/Headers/zlib -I${SRCROOT}/Headers/libssh2  -I${SRCROOT}/Headers/openssl" LDFLAGS="-L${SRCROOT}/Libraries/linux" LIBS="-ldl" ./configure --disable-dependency-tracking --enable-static --disable-shared --with-ssl --with-zlib --with-libssh2 --without-tests --prefix="${PREFIX}"

make -j install

# Copy the library files.

cp _build_linux/lib/libcurl.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}

