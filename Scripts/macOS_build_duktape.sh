#!/bin/bash
set -e

cd ../Output
export OUTPUT=`pwd`

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Remove old source

rm -rf duktape
mkdir duktape
tar -xf ../duktape.tar.xz -C duktape --strip-components=1
cd duktape

# Copy the source files.

cp -R src "${OUTPUT}/Source/duktape"

# Return to source directory

cd ${SRCROOT}
