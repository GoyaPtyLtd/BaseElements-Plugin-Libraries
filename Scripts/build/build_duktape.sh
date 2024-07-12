#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ..
export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Switch to our build directory

cd ../source/macOS

rm -rf duktape
mkdir duktape
tar -xf ../duktape.tar.xz -C duktape --strip-components=1
cd duktape

# Copy the source files.

cp -R src "${OUTPUT}/Source/duktape"

# Return to source directory

cd ${SRCROOT}
