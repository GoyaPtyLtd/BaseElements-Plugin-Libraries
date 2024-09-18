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


SRCROOT=$(pwd)
cd ../../Output
OUTPUT=$(pwd)

# Remove old libraries

rm -f Libraries/macOS/libfontconfig.a

rm -rf Headers/fontconfig
mkdir Headers/fontconfig

# Switch to our build directory

cd ../source/${PLATFORM}

export LIBEXPAT=`pwd`'/libexpat/_build'

rm -rf fontconfig
mkdir fontconfig
tar -xf ../fontconfig.tar.gz -C fontconfig --strip-components=1
cd fontconfig

mkdir _build
export PREFIX=`pwd`'/_build'

# Build macOS

if [ ${PLATFORM} = 'macOS' ]; then

	CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.15" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}" \
	FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/${PLATFORM} -lfreetype" \
	./configure --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
	--with-expat=${LIBEXPAT} \
	--prefix="${PREFIX}"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	CFLAGS="-fPIC" \
	LDFLAGS="-L${OUTPUT}/Libraries/${PLATFORM}" \
	FREETYPE_CFLAGS="-I${OUTPUT}/Headers/freetype2" FREETYPE_LIBS="-L${OUTPUT}/Libraries/${PLATFORM} -lfreetype" \
	./configure --disable-shared --disable-docs --disable-cache-build --disable-dependency-tracking --disable-silent-rules \
	--with-expat=${LIBEXPAT} \
	--prefix="${PREFIX}"

fi

make -j${JOBS}
make install

# Copy the header and library files.

cp -R _build/include/fontconfig/* "${OUTPUT}/Headers/fontconfig"
cp _build/lib/libfontconfig.a "${OUTPUT}/Libraries/${PLATFORM}"

cd "${SRCROOT}"
