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

cd ..
export SRCROOT=`pwd`
cd ../Output
export OUTPUT=`pwd`

# Remove old libraries

rm -f Libraries/${PLATFORM}/libPocoCrypto.a
rm -f Libraries/${PLATFORM}/libPocoFoundation.a
rm -f Libraries/${PLATFORM}/libPocoJSON.a
rm -f Libraries/${PLATFORM}/libPocoNet.a
rm -f Libraries/${PLATFORM}/libPocoPDF.a
rm -f Libraries/${PLATFORM}/libPocoXML.a
rm -f Libraries/${PLATFORM}/libPocoZip.a

if [ ${PLATFORM} = 'macOS' ]; then
	rm -rf Headers/Poco
	mkdir Headers/Poco
fi

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf poco
mkdir poco
tar -xf ../poco.tar.gz -C poco --strip-components=1
cd poco

mkdir _build
mkdir _build_x86_64
mkdir _build_arm64

export PREFIX=`pwd`'/_build'
export PREFIX_x86_64=`pwd`'/_build_x86_64'
export PREFIX_arm64=`pwd`'/_build_arm64'

# Build

if [ ${PLATFORM} = 'macOS' ]; then

	./configure --cflags="-mmacosx-version-min=10.15" \
	--prefix="${PREFIX_x86_64}" \
	--no-sharedlibs --static --poquito --no-tests --no-samples \
	--omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis,Util" \
	--include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/${PLATFORM}"

	make install -s -j4 POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=x86_64 POCO_TARGET_OSARCH=x86_64
	# Needs a change to just the POCO_TARGET_OSARCH once the bug in their config is fixed - now needs both so it builds into the right folders
	# It is ignoring the target value
	make -s -j distclean

	./configure --cflags="-mmacosx-version-min=10.15" \
	--prefix="${PREFIX_arm64}" \
	--no-sharedlibs --static --poquito --no-tests --no-samples \
	--omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis,Util" \
	--include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/${PLATFORM}"

	make install -s -j4 POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=arm64 POCO_TARGET_OSARCH=x86_64
	# Needs a change to just the POCO_TARGET_OSARCH once the bug in their config is fixed - now needs both so it builds into the right folders
	# It is ignoring the target value
	make -s -j distclean

	mkdir ${PREFIX}/lib

	lipo -create "${PREFIX_x86_64}/lib/libPocoCrypto.a" "${PREFIX_arm64}/lib/libPocoCrypto.a" -output "${PREFIX}/lib/libPocoCrypto.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoFoundation.a" "${PREFIX_arm64}/lib/libPocoFoundation.a" -output "${PREFIX}/lib/libPocoFoundation.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoJSON.a" "${PREFIX_arm64}/lib/libPocoJSON.a" -output "${PREFIX}/lib/libPocoJSON.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoNet.a" "${PREFIX_arm64}/lib/libPocoNet.a" -output "${PREFIX}/lib/libPocoNet.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoPDF.a" "${PREFIX_arm64}/lib/libPocoPDF.a" -output "${PREFIX}/lib/libPocoPDF.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoXML.a" "${PREFIX_arm64}/lib/libPocoXML.a" -output "${PREFIX}/lib/libPocoXML.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoZip.a" "${PREFIX_arm64}/lib/libPocoZip.a" -output "${PREFIX}/lib/libPocoZip.a"

elif [ ${PLATFORM} = 'linux' ]||[ ${PLATFORM} = 'linuxARM' ]; then

	./configure --cflags=-fPIC \
	--prefix="${PREFIX}" \
	--no-sharedlibs --static --poquito --no-tests --no-samples \
	--omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis,Util" \
	--include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/${PLATFORM}"

	make -j install
	
fi

# Copy the header and library files.

if [ ${PLATFORM} = 'macOS' ]; then
	cp -R _build_x86_64/include/Poco/* "${OUTPUT}/Headers/Poco"
fi

cp _build/lib/libPocoCrypto.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoFoundation.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoJSON.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoNet.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoPDF.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoXML.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoZip.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd ${SRCROOT}

