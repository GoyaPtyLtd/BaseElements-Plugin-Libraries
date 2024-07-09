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
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/${PLATFORM}/libcrypto.a
rm -f Libraries/${PLATFORM}/libssl.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/openssl
	mkdir Headers/openssl
fi

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
	./configure darwin64-x86_64-cc no-engine no-hw no-shared \
	--prefix="${PREFIX_x86_64}"
	
	#first build is install so we get headers
	make install
	make -s -j distclean

	mkdir _build_arm64
	export PREFIX_arm64=`pwd`'/_build_arm64'

	CFLAGS="-mmacosx-version-min=10.15" \
	./configure darwin64-arm64-cc no-engine no-hw no-shared \
	--prefix="${PREFIX_arm64}"
	
	#install_sw leaves out headers
	make install_sw
	make -s -j distclean

	lipo -create "${PREFIX_x86_64}/lib/libcrypto.a" "${PREFIX_arm64}/lib/libcrypto.a" -output "${PREFIX}/libcrypto.a"
	lipo -create "${PREFIX_x86_64}/lib/libssl.a" "${PREFIX_arm64}/lib/libssl.a" -output "${PREFIX}/libssl.a"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	./Configure linux-generic64 no-engine no-hw no-shared \
	--prefix="${PREFIX}"
	make -j install

fi

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build_x86_64/include/openssl/* "${OUTPUT}/Headers/openssl"
fi

cp _build/libcrypto.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/libssl.a "${OUTPUT}/Libraries/${PLATFORM}"

cd ${SRCROOT}
