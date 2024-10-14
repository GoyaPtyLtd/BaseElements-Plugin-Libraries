#!/bin/bash
set -e

echo "Starting $(basename "$0") Build"

OS=$(uname -s)		# Linux|Darwin
ARCH=$(uname -m)	# x86_64|aarch64|arm64
JOBS=1              # Number of parallel jobs
if [[ $OS = 'Darwin' ]]; then
    PLATFORM='macOS'
    JOBS=$(($(sysctl -n hw.logicalcpu) + 1))
    if [[ $ARCH = 'aarch64' ]]; then
        HOST='arm64'
    elif [[ $ARCH = 'x86_64' ]]; then
        HOST='x86_64'
    fi
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


SRCROOT=${PWD}
cd ../../Output
OUTPUT=${PWD}

# Remove old libraries

rm -f Libraries/${PLATFORM}/libPocoCrypto.a
rm -f Libraries/${PLATFORM}/libPocoFoundation.a
rm -f Libraries/${PLATFORM}/libPocoJSON.a
rm -f Libraries/${PLATFORM}/libPocoNet.a
rm -f Libraries/${PLATFORM}/libPocoUtil.a
rm -f Libraries/${PLATFORM}/libPocoXML.a
rm -f Libraries/${PLATFORM}/libPocoZip.a

rm -rf Headers/Poco
mkdir Headers/Poco

# Switch to our build directory

cd ../source/${PLATFORM}

rm -rf poco
mkdir poco
tar -xf ../poco.tar.gz -C poco --strip-components=1
cd poco

mkdir _build

PREFIX=${PWD}'/_build'

# Build

if [[ $PLATFORM = 'macOS' ]]; then

	mkdir _build_x86_64
	mkdir _build_arm64
	mkdir _build_iPhone
	mkdir _build_iPhoneSim_x86
	mkdir _build_iPhoneSim_arm

	PREFIX_x86_64=${PWD}'/_build_x86_64'
	PREFIX_arm64=${PWD}'/_build_arm64'
	PREFIX_iPhone=${PWD}'/_build_iPhone'
	PREFIX_iPhoneSim_x86=${PWD}'/_build_iPhoneSim_x86'
	PREFIX_iPhoneSim_arm=${PWD}'/_build_iPhoneSim_arm'

	#mac OS

	./configure --cflags="-mmacosx-version-min=10.15" \
	--prefix="${PREFIX_x86_64}" \
	--no-sharedlibs --static --poquito --no-tests --no-samples \
	--omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
	--include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/${PLATFORM}"

	make -j${JOBS} POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=x86_64 POCO_TARGET_OSARCH=${HOST}
	make install POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=x86_64 POCO_TARGET_OSARCH=${HOST}
	make -s distclean

	./configure --cflags="-mmacosx-version-min=10.15" \
	--prefix="${PREFIX_arm64}" \
	--no-sharedlibs --static --poquito --no-tests --no-samples \
	--omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
	--include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/${PLATFORM}"

	make -j${JOBS} POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=arm64 POCO_TARGET_OSARCH=${HOST}
	make install POCO_CONFIG=Darwin64-clang-libc++ MACOSX_DEPLOYMENT_TARGET=10.15 POCO_HOST_OSARCH=arm64 POCO_TARGET_OSARCH=${HOST}
	make -s distclean

	mkdir ${PREFIX}/lib

	cp -R _build_x86_64/include/Poco/* "${OUTPUT}/Headers/Poco"

	lipo -create "${PREFIX_x86_64}/lib/libPocoCrypto.a" "${PREFIX_arm64}/lib/libPocoCrypto.a" -output "${PREFIX}/lib/libPocoCrypto.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoFoundation.a" "${PREFIX_arm64}/lib/libPocoFoundation.a" -output "${PREFIX}/lib/libPocoFoundation.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoJSON.a" "${PREFIX_arm64}/lib/libPocoJSON.a" -output "${PREFIX}/lib/libPocoJSON.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoNet.a" "${PREFIX_arm64}/lib/libPocoNet.a" -output "${PREFIX}/lib/libPocoNet.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoXML.a" "${PREFIX_arm64}/lib/libPocoXML.a" -output "${PREFIX}/lib/libPocoXML.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoUtil.a" "${PREFIX_arm64}/lib/libPocoUtil.a" -output "${PREFIX}/lib/libPocoUtil.a"
	lipo -create "${PREFIX_x86_64}/lib/libPocoZip.a" "${PREFIX_arm64}/lib/libPocoZip.a" -output "${PREFIX}/lib/libPocoZip.a"

: <<END_COMMENT
	#iOS

	./configure --cflags="-miphoneos-version-min=15.0" \
	--prefix="${PREFIX_iPhone}" \
	--no-sharedlibs --static --poquito --no-tests --no-samples \
	--omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
	--include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/iOS"

	make -j${JOBS} POCO_CONFIG=iPhone-clang-libc++ IPHONEOS_DEPLOYMENT_TARGET=15.0
	make install POCO_CONFIG=iPhone-clang-libc++ IPHONEOS_DEPLOYMENT_TARGET=15.0
	make -s distclean

	cp _build_iPhone/lib/libPocoCrypto.a "${OUTPUT}/Libraries/iOS"
	cp _build_iPhone/lib/libPocoFoundation.a "${OUTPUT}/Libraries/iOS"
	cp _build_iPhone/lib/libPocoJSON.a "${OUTPUT}/Libraries/iOS"
	cp _build_iPhone/lib/libPocoNet.a "${OUTPUT}/Libraries/iOS"
	cp _build_iPhone/lib/libPocoXML.a "${OUTPUT}/Libraries/iOS"
	cp _build_iPhone/lib/libPocoUtil.a "${OUTPUT}/Libraries/iOS"
	cp _build_iPhone/lib/libPocoZip.a "${OUTPUT}/Libraries/iOS"

	#iOS Simulator

	./configure --cflags="-miphoneos-version-min=15.0" \
	--prefix="${PREFIX_iPhoneSim_arm}" \
	--no-sharedlibs --static --poquito --no-tests --no-samples \
	--omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
	--include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/iOS"

	make -j${JOBS} POCO_CONFIG=iPhoneSimulator IPHONEOS_DEPLOYMENT_TARGET=15.0 POCO_HOST_OSARCH=arm64
	make install
	make -s distclean

	./configure --cflags="-miphoneos-version-min=15.0" \
	--prefix="${PREFIX_iPhoneSim_x86}" \
	--no-sharedlibs --static --poquito --no-tests --no-samples \
	--omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
	--include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/iOS"

	make -j${JOBS} POCO_CONFIG=iPhoneSimulator IPHONEOS_DEPLOYMENT_TARGET=15.0 POCO_HOST_OSARCH=x86_64
	make install
	make -s distclean
END_COMMENT


elif [[ $OS = 'Linux' ]]; then

	./configure --cflags=-fPIC \
	--config=Linux-clang \
	--prefix="${PREFIX}" \
	--no-sharedlibs --static --poquito --no-tests --no-samples \
	--omit="CppParser,Data,Encodings,MongoDB,PageCompiler,Redis" \
	--include-path="${OUTPUT}/Headers" --library-path="${OUTPUT}/Libraries/${PLATFORM}"

	make -j${JOBS}
	make install

fi

# Copy the header and library files.

cp -R _build/include/Poco/* "${OUTPUT}/Headers/Poco"

cp _build/lib/libPocoCrypto.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoFoundation.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoJSON.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoNet.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoXML.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoUtil.a "${OUTPUT}/Libraries/${PLATFORM}"
cp _build/lib/libPocoZip.a "${OUTPUT}/Libraries/${PLATFORM}"

# Return to source directory

cd "${SRCROOT}"

