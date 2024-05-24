#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/linux/libfreetype.a
rm Libraries/linux/libfontconfig.a

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

#====freetype2====

# Switch to our build directory

rm -rf freetype
mkdir freetype
tar -xf ../freetype.tar.gz -C freetype --strip-components=1
cd freetype
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

CFLAGS="-fPIC" ./configure --disable-shared --prefix="${PREFIX}"
make -s -j install

# Copy the library files.

cp _build_linux/lib/libfreetype.a "${OUTPUT}/Libraries/linux"

cd ${SRCROOT}

#====fontconfig====

# Switch to our build directory

rm -rf fontconfig
mkdir fontconfig
tar -xf ../fontconfig.tar.gz -C fontconfig --strip-components=1
cd fontconfig
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

LIBS="-lz" CFLAGS="-fPIC" ./configure --disable-shared --prefix="${PREFIX}" FREETYPE_CFLAGS="-I${SRCROOT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/linux -lfreetype" LDFLAGS="-L${OUTPUT}/Libraries/linux"
make -s -j install

# Copy the library files.

cp _build_linux/lib/libfontconfig.a "${OUTPUT}/Libraries/linux"

cd ${SRCROOT}

#====podofo====

# Switch to our build directory

rm -rf podofo
mkdir podofo
tar -xf ../podofo.tar.gz -C podofo --strip-components=1
cd podofo
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DPODOFO_BUILD_STATIC:BOOL=TRUE -DFREETYPE_LIBRARY_RELEASE="${SRCROOT}/Libraries/linuxARM/libfreetype.a" -DFontconfig_INCLUDE_DIR="${SRCROOT}/Headers/fontconfig" -DFontconfig_LIBRARIES="${SRCROOT}/Libraries/linuxARM" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_CXX_FLAGS="-fPIC" ./
make -s -j install

# Copy the library files.

cp _build_linux/lib/libpodofo.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}
