#!/bin/bash

cd ../../..
export START=`pwd`

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


cd BaseElements-Plugin-Libraries/Output
export OUTPUT=`pwd`

cp Libraries/${PLATFORM}/libz.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libcrypto.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libssl.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libssh2.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libnghttp2.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libcurl.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

cp Libraries/${PLATFORM}/libPocoCrypto.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libPocoFoundation.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libPocoJSON.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libPocoNet.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libPocoUtil.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libPocoXML.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"
cp Libraries/${PLATFORM}/libPocoZip.a "${START}/BaseElements-Plugin/Libraries/${PLATFORM}"

if [ ${PLATFORM} = 'macOS' ]; then

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/zlib/" "${START}/BaseElements-Plugin/Headers/zlib"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/openssl/" "${START}/BaseElements-Plugin/Headers/openssl"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/libssh2/" "${START}/BaseElements-Plugin/Headers/libssh2"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/nghttp2/" "${START}/BaseElements-Plugin/Headers/nghttp2"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/curl/" "${START}/BaseElements-Plugin/Headers/curl"

	rsync -rv --delete --no-group --no-owner --no-perms --no-times --checksum  --stats "${OUTPUT}/Headers/Poco/" "${START}/BaseElements-Plugin/Headers/Poco"

fi
