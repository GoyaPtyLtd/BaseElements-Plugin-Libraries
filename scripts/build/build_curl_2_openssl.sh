#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

if [ $(uname) = 'Darwin' ]; then
	export PLATFORM='macOS'
elif [ $(uname -m) = 'aarch64' ]; then
	export PLATFORM='linuxARM'
else
	export PLATFORM='linux'
fi

export SRCROOT=`pwd`
cd ../../Output
export OUTPUT=`pwd`

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

if [ ${PLATFORM} = 'macOS' ]; then

	mkdir _build_x86_64
	export PREFIX_x86_64=`pwd`'/_build_x86_64'

	CFLAGS="-mmacosx-version-min=10.15" \
	./configure darwin64-x86_64-cc no-shared no-docs no-tests \
	--prefix="${PREFIX_x86_64}"
	
	make install
	make -s -j distclean

	mkdir _build_arm64
	export PREFIX_arm64=`pwd`'/_build_arm64'

	CFLAGS="-mmacosx-version-min=10.15" \
	./configure darwin64-arm64-cc no-shared no-docs no-tests \
	--prefix="${PREFIX_arm64}"
	
	make install
	make -s -j distclean

	mkdir ${PREFIX}/lib

	lipo -create "${PREFIX_x86_64}/lib/libcrypto.a" "${PREFIX_arm64}/lib/libcrypto.a" -output "${PREFIX}/lib/libcrypto.a"
	lipo -create "${PREFIX_x86_64}/lib/libssl.a" "${PREFIX_arm64}/lib/libssl.a" -output "${PREFIX}/lib/libssl.a"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	./Configure linux-generic64 no-shared no-docs no-tests \
	--prefix="${PREFIX}"
	make
	make -j install_sw

fi

# Copy the header and library files.

cp -R _build_x86_64/include/openssl/* "${OUTPUT}/Headers/openssl"

cp _build/lib/libcrypto.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libssl.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
