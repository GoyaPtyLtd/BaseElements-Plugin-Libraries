#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm -f Libraries/macOS/libboost_atomic.a
rm -f Libraries/macOS/libboost_date_time.a
rm -f Libraries/macOS/libboost_filesystem.a
rm -f Libraries/macOS/libboost_program_options.a
rm -f Libraries/macOS/libboost_regex.a
rm -f Libraries/macOS/libboost_thread.a

rm -rf Headers/boost
mkdir Headers/boost

# Switch to our build directory

cd ../source/macOS

rm -rf boost
mkdir boost
tar -xf ../boost.tar.gz -C boost --strip-components=1
cd boost

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`'/_build_macos'
export PREFIX_ios=`pwd`'/_build_ios'

# Build macOS

./bootstrap.sh
./b2 toolset=clang cxxflags="-arch arm64 -arch x86_64" address-model=64 link=static runtime-link=static install --prefix="${PREFIX}" --with-program_options --with-regex --with-date_time --with-filesystem --with-thread cxxflags="-mmacosx-version-min=10.15 -stdlib=libc++" linkflags="-stdlib=libc++"

# Copy the header and library files.

cp -R _build_macos/include/boost/* "${OUTPUT}/Headers/boost"

cp _build_macos/lib/libboost_atomic.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libboost_date_time.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libboost_filesystem.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libboost_program_options.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libboost_regex.a "${OUTPUT}/Libraries/macOS"
cp _build_macos/lib/libboost_thread.a "${OUTPUT}/Libraries/macOS"

#Build iOS

./iOS_build_boost.sh  -ios --boost-version 1.75.0 --boost-libs "program_options regex date_time filesystem thread"

cp -R dist/boost.xcframework "${OUTPUT}/Libraries/iOS"

# Return to source directory

cd ${SRCROOT}
