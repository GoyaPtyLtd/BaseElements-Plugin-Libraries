#!/bin/bash -E

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm Libraries/macOS/libboost_atomic.a
rm Libraries/macOS/libboost_date_time.a
rm Libraries/macOS/libboost_filesystem.a
rm Libraries/macOS/libboost_program_options.a
rm Libraries/macOS/libboost_regex.a
rm Libraries/macOS/libboost_thread.a

rm -rf Headers/boost/*

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf boost
mkdir boost
tar -xf ../boost.tar.gz -C boost --strip-components=1
cd boost

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

./bootstrap.sh
./b2 toolset=clang cxxflags="-arch arm64 -arch x86_64" address-model=64 link=static runtime-link=static install --prefix="${PREFIX}" --with-program_options --with-regex --with-date_time --with-filesystem --with-thread cxxflags="-mmacosx-version-min=10.15 -stdlib=libc++" linkflags="-stdlib=libc++"

# Copy the header and library files.

cp -R "${PREFIX}/include/boost" "${OUTPUT}/Headers"

cp "${PREFIX}/lib/libboost_atomic.a" "${OUTPUT}/Libraries/macOS"
cp "${PREFIX}/lib/libboost_date_time.a" "${OUTPUT}/Libraries/macOS"
cp "${PREFIX}/lib/libboost_filesystem.a" "${OUTPUT}/Libraries/macOS"
cp "${PREFIX}/lib/libboost_program_options.a" "${OUTPUT}/Libraries/macOS"
cp "${PREFIX}/lib/libboost_regex.a" "${OUTPUT}/Libraries/macOS"
cp "${PREFIX}/lib/libboost_thread.a" "${OUTPUT}/Libraries/macOS"

# Return to source directory

cd ${SRCROOT}

