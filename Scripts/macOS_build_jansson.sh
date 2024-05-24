#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/macOS/libjansson.a
rm -rf Headers/jansson.h
rm -rf Headers/jansson_config.h

# Starting folder

cd ../source/macOS
export SRCROOT=`pwd`

# Switch to our build directory

rm -rf jansson
mkdir jansson
tar -xf ../jansson.tar.gz -C jansson --strip-components=1
cd jansson

mkdir _build_macos
mkdir _build_ios
mkdir _build_iosSimulator
mkdir _build_iosSimulatorArm
mkdir _build_iosSimulatorx86

export PREFIX=`pwd`'/_build_macos'
export PREFIX_ios=`pwd`'/_build_ios'
export PREFIX_iosSimulator=`pwd`'/_build_iosSimulator'
export PREFIX_iosSimulatorArm=`pwd`'/_build_iosSimulatorArm'
export PREFIX_iosSimulatorx86=`pwd`'/_build_iosSimulatorx86'

# Build macOS

autoupdate
autoreconf -fi

./configure --quiet --host=x86_64 --prefix="${PREFIX}" CFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" --disable-shared

make -s -j install

# Copy the header and library files.

cp "${PREFIX}/include/jansson.h" "${OUTPUT}/Headers/"
cp "${PREFIX}/include/jansson_config.h" "${OUTPUT}/Headers/"

cp "${PREFIX}/lib/libjansson.a" "${OUTPUT}/Libraries/macOS/"

# Return to source directory

cd ${SRCROOT}
