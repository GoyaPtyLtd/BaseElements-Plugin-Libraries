#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/linux/libiconv.a
rm Libraries/linux/libcharset.a

rm Libraries/linux/libxml2.a

rm Libraries/linux/libxslt.a
rm Libraries/linux/libexslt.a

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

#====libiconv====

# Switch to our build directory

rm -rf libiconv
mkdir libiconv
tar -xf ../libiconv.tar.gz -C libiconv --strip-components=1
cd libiconv
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'
export PREFIX=`pwd`'/_build_linux'

export ICONV=`pwd`

# Build

CFLAGS=-fPIC ./configure --disable-shared --prefix="${PREFIX}"
make install

# Copy the library files.

cp _build_linux/lib/libiconv.a "${OUTPUT}/Libraries/linux"
cp _build_linux/lib/libcharset.a "${OUTPUT}/Libraries/linux"

cd ${SRCROOT}

#====libxml2====

# Switch to our build directory

rm -rf libxml
mkdir libxml
tar -xf ../libxml.tar.gz -C libxml --strip-components=1
cd libxml
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'
export PREFIX=`pwd`'/_build_linux'

export LIBXML=`pwd`

# Build

CFLAGS=-fPIC ./configure --disable-shared --with-threads --without-python --without-zlib --without-lzma --prefix="${PREFIX}"
make -s -j install

# Copy the library files.

cp _build_linux/lib/libxml2.a "${OUTPUT}/Libraries/linux"

cd ${SRCROOT}

#====libxslt====

# Switch to our build directory

rm -rf libxslt
mkdir libxslt
tar -xf ../libxslt.tar.gz -C libxslt --strip-components=1
cd libxslt
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'
export PREFIX=`pwd`'/_build_linux'

# Build

CFLAGS=-fPIC ./configure --disable-shared --without-python --without-crypto --prefix="${PREFIX}"
make -s -j install

# Copy the library files.

cp _build_linux/lib/libxslt.a "${OUTPUT}/Libraries/linux"
cp _build_linux/lib/libexslt.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}

