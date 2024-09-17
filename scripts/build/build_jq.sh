#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1              # Number of parallel jobs
if [[ $OS = 'Darwin' ]]; then
	PLATFORM='macOS'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
elif [[ $OS = 'Linux' ]]; then
    JOBS=$(($(nproc) + 1))
    if [[ $ARCH = 'aarch64' ]]; then
        PLATFORM='linuxARM'
    elif [[ $ARCH = 'x86_64' ]]; then
        PLATFORM='linux'
    fi
fi
if [[ "${PLATFORM}X" = 'X' ]]; then     # $PLATFORM is empty
	echo "!! Unknown OS/ARCH: $OS/$ARCH"
	exit 1
fi


export SRCROOT=`pwd`
cd ../../Output
export OUTPUT=`pwd`

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libjq.a

rm -rf Headers/jq
mkdir Headers/jq

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf jq
mkdir jq
tar -xf ../jq.tar.gz  -C jq --strip-components=1
cd jq

mkdir _build
export PREFIX=`pwd`'/_build'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared \
	--enable-all-static --enable-pthread-tls --without-oniguruma \
	--prefix="${PREFIX}"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	./configure --disable-maintainer-mode --disable-dependency-tracking --disable-docs --disable-shared \
	--enable-all-static --enable-pthread-tls --without-oniguruma \
	--prefix="${PREFIX}"

	make -j$(($(nproc) + 1))

fi

make install

# Copy the header and library files.

# jq seems to require the version.h file, but doesn't put it into the prefix.
cp src/version.h "${OUTPUT}/Headers/jq"
cp -R _build/include/* "${OUTPUT}/Headers/jq"

cp _build/lib/libjq.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
