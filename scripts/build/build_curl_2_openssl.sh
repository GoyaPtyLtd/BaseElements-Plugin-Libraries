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

# Remove old libraries and headers

rm -f Libraries/${PLATFORM}/libcrypto.a
rm -f Libraries/${PLATFORM}/libssl.a

rm -rf Headers/openssl
mkdir Headers/openssl

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf openssl
mkdir openssl
tar -xf ../openssl.tar.gz -C openssl --strip-components=1
cd openssl

mkdir _build
export PREFIX=`pwd`'/_build'

if [[ $PLATFORM = 'macOS' ]]; then

	mkdir _build_x86_64
	export PREFIX_x86_64=`pwd`'/_build_x86_64'

	CFLAGS="-mmacosx-version-min=10.15" \
	./configure darwin64-x86_64-cc no-shared no-docs no-tests \
	--prefix="${PREFIX_x86_64}"

	make -j${JOBS}
	make install
	make -s distclean

	mkdir _build_arm64
	export PREFIX_arm64=`pwd`'/_build_arm64'

	CFLAGS="-mmacosx-version-min=10.15" \
	./configure darwin64-arm64-cc no-shared no-docs no-tests \
	--prefix="${PREFIX_arm64}"

	make -j${JOBS}
	make install
	make -s distclean

	mkdir ${PREFIX}/lib

	lipo -create "${PREFIX_x86_64}/lib/libcrypto.a" "${PREFIX_arm64}/lib/libcrypto.a" -output "${PREFIX}/lib/libcrypto.a"
	lipo -create "${PREFIX_x86_64}/lib/libssl.a" "${PREFIX_arm64}/lib/libssl.a" -output "${PREFIX}/lib/libssl.a"

elif [[ $OS = 'Linux' ]]; then

	./Configure linux-generic64 no-shared no-docs no-tests \
	--prefix="${PREFIX}"
	make -j${JOBS}
	make install_sw

fi

# Copy the header and library files.

if [[ $PLATFORM = 'macOS' ]]; then
	cp -R _build_x86_64/include/openssl/* "${OUTPUT}/Headers/openssl"
else
	cp -R _build/include/openssl/* "${OUTPUT}/Headers/openssl"
fi

cp _build/lib/libcrypto.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libssl.a "${OUTPUT}/Libraries/${PLATFORM}"

cd "${SRCROOT}"
