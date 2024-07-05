#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm -f Libraries/linux/libboost_atomic.a
rm -f Libraries/linux/libboost_date_time.a
rm -f Libraries/linux/libboost_filesystem.a
rm -f Libraries/linux/libboost_program_options.a
rm -f Libraries/linux/libboost_regex.a
rm -f Libraries/linux/libboost_thread.a

# Starting folder

cd ../source/linux
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf boost
mkdir boost
tar -xf ../boost.tar.gz -C boost --strip-components=1
cd boost
mkdir _build_linux
export PREFIX=`pwd`'/_build_linux'

# Build

./bootstrap.sh
./b2 link=static cflags=-fPIC cxxflags=-fPIC runtime-link=static install --prefix="${PREFIX}" --with-program_options --with-regex --with-date_time --with-filesystem --with-thread

# Copy the library files.

cp _build_linux/lib/libboost_atomic.a "${OUTPUT}/Libraries/linux"
cp _build_linux/lib/libboost_date_time.a "${OUTPUT}/Libraries/linux"
cp _build_linux/lib/libboost_filesystem.a "${OUTPUT}/Libraries/linux"
cp _build_linux/lib/libboost_program_options.a "${OUTPUT}/Libraries/linux"
cp _build_linux/lib/libboost_regex.a "${OUTPUT}/Libraries/linux"
cp _build_linux/lib/libboost_thread.a "${OUTPUT}/Libraries/linux"

# Return to source directory

cd ${SRCROOT}

