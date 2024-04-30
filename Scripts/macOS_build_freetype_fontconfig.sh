#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm Libraries/macOS/libfreetype.a
rm Libraries/macOS/libfontconfig.a

# Remove old headers

rm -rf Headers/freetype2/*
rm -rf Headers/fontconfig/*

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

#====freetype2====

# Switch to our build directory

rm -rf freetype
mkdir freetype
tar -xf ../freetype.tar.gz -C freetype --strip-components=1
cd freetype

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'
export PREFIX_ios=`pwd`+'/_build_ios'
export PREFIX_iosSimulator=`pwd`+'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'/_build_iosSimulatorx86'

# Build macOS

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" ./configure --disable-shared --with-png=no --with-bzip2=no --with-harfbuzz=no --with-png=no --with-zlib=no --${PREFIX}

make -s -j install

# Copy the header and library files.

cp -R "${PREFIX}/include/freetype2" "${OUTPUT}/Headers"
cp "${PREFIX}/lib/libfreetype.a" "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====fontconfig====

# Switch to our build directory

rm -rf fontconfig
mkdir fontconfig
tar -xf ../fontconfig.tar.gz -C fontconfig --strip-components=1
cd fontconfig

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'
export PREFIX_ios=`pwd`+'/_build_ios'
export PREFIX_iosSimulator=`pwd`+'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'/_build_iosSimulatorx86'

# Build macOS

CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" ./configure --disable-shared --prefix="${PREFIX}" FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/macOS -lfreetype" LDFLAGS="-L${OUTPUT}/Libraries/macOS"
make -s -j install

# Copy the header and library files.

cp -R "${PREFIX}/include/fontconfig" "${OUTPUT}/Headers"
cp "${PREFIX}/lib/libfontconfig.a" "${OUTPUT}/Libraries/macOS"

cd ${SRCROOT}

#====podofo====

# Switch to our build directory

rm -rf podofo
mkdir podofo
tar -xf ../podofo.tar.gz -C podofo --strip-components=1
cd podofo

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`+'/_build_macos'
export PREFIX_ios=`pwd`+'/_build_ios'
export PREFIX_iosSimulator=`pwd`+'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`+'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`+'/_build_iosSimulatorx86'

# Build macOS

cmake -G "Unix Makefiles" -DWANT_FONTCONFIG:BOOL=TRUE -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DPODOFO_BUILD_STATIC:BOOL=TRUE -DFREETYPE_INCLUDE_DIR="${OUTPUT}/Headers/freetype2" -DFREETYPE_LIBRARY_RELEASE="${OUTPUT}/Libraries/macOS/libfreetype.a" -DFONTCONFIG_LIBRARIES="${OUTPUT}/Libraries" -DFONTCONFIG_INCLUDE_DIR="${OUTPUT}/Headers" -DFONTCONFIG_LIBRARY_RELEASE="${OUTPUT}/Libraries/macOS/libfontconfig.a" -DPODOFO_BUILD_LIB_ONLY=TRUE -DCMAKE_C_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" -DCMAKE_CXX_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15 -stdlib=libc++" -DCMAKE_CXX_STANDARD=11 -DCXX_STANDARD_REQUIRED=ON ./
make -s -j install

# Copy the header and library files.

cp -R "${PREFIX}/include/podofo" "${OUTPUT}/Headers"
cp "${PREFIX}/lib/libpodofo.a" "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}
