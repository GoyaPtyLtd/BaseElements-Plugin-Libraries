#!/bin/bash

# iPhone version

# https://github.com/libjpeg-turbo/libjpeg-turbo/blob/main/BUILDING.md

IOS_PLATFORMDIR=$(xcrun --sdk iphoneos --show-sdk-platform-path)
IOS_SYSROOT=$(xcrun --sdk iphoneos --show-sdk-path)

export CFLAGS="-Wall -arch arm64 -miphoneos-version-min=13.2 -funwind-tables"

cat <<EOF >toolchain.cmake
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang)
EOF

cmake -G"Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
  -DCMAKE_OSX_SYSROOT=${IOS_SYSROOT[0]} \
  .
make

#mv -v ./libturbojpeg.a ../libs/libturbojpeg_arm64_a

make clean

# Simulator version

IOS_SIMULATOR_PLATFORMDIR=$(xcrun --sdk iphonesimulator --show-sdk-platform-path)
IOS_SIMULATOR_SYSROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

export CFLAGS="-Wall -arch x86_64 arm64 -miphoneos-version-min=13.2 -funwind-tables"

cat <<EOF >toolchain.cmake
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_C_COMPILER /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang)
EOF

cmake -G"Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
  -DCMAKE_OSX_SYSROOT=${IOS_SIMULATOR_SYSROOT[0]} \
  .
make

#mv -v ./libturbojpeg.a ../libs/libturbojpeg_arm64_a

make clean
