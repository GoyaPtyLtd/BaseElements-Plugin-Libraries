#!/bin/bash -E

export START=`pwd`

cd ../Output
export SRCROOT=`pwd`

# Remove old libraries

rm macOS/libboost_atomic.a
rm macOS/libboost_date_time.a
rm macOS/libboost_filesystem.a
rm macOS/libboost_program_options.a
rm macOS/libboost_regex.a
rm macOS/libboost_thread.a

# Remove old headers

rm -rf Headers/boost/*

# Switch to our build directory

cd ../source/macOS/boost

# Remove old build directory contents
 
mkdir _build_macos
rm -rf _build_macos/*

# Build

./bootstrap.sh
./b2 toolset=clang cxxflags="-arch arm64 -arch x86_64" address-model=64 link=static runtime-link=static install --prefix=_build_macos --with-program_options --with-regex --with-date_time --with-filesystem --with-thread cxxflags="-mmacosx-version-min=10.15 -stdlib=libc++" linkflags="-stdlib=libc++"

# Copy the header and library files.

cp -R _build_macos/include/boost "${SRCROOT}/Headers"

cp _build_macos/lib/libboost_atomic.a "${SRCROOT}/Libraries/macOS"
cp _build_macos/lib/libboost_date_time.a "${SRCROOT}/Libraries/macOS"
cp _build_macos/lib/libboost_filesystem.a "${SRCROOT}/Libraries/macOS"
cp _build_macos/lib/libboost_program_options.a "${SRCROOT}/Libraries/macOS"
cp _build_macos/lib/libboost_regex.a "${SRCROOT}/Libraries/macOS"
cp _build_macos/lib/libboost_thread.a "${SRCROOT}/Libraries/macOS"

# Return to source/macOS directory

cd "START"
