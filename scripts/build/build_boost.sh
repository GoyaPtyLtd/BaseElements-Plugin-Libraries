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

LIBS=(
    libboost_atomic.a
    libboost_date_time.a
    libboost_filesystem.a
    libboost_locale.a
    libboost_program_options.a
    libboost_regex.a
    libboost_thread.a
)

for LIB in "${LIBS[@]}"; do
    rm -f Libraries/"${PLATFORM}"/"${LIB}"
done

rm -rf Headers/boost
mkdir Headers/boost

# Switch to our build directory

cd ../source/"${PLATFORM}"

rm -rf boost
mkdir boost
tar -xf ../boost.tar.gz -C boost --strip-components=1
cd boost

mkdir _build
PREFIX=$(pwd)/_build

# Build

./bootstrap.sh

CXXFLAGS=()
LINKFLAGS=()
if [[ $PLATFORM = 'macOS' ]]; then
    CXXFLAGS+=(
        -arch arm64
        -arch x86_64
        '-mmacosx-version-min=10.15'
        '-stdlib=libc++'
    )
    LINKFLAGS+=(
        '-stdlib=libc++'
    )
elif [[ $OS = 'Linux' ]]; then
    CXXFLAGS+=(
        -fPIC
    )
fi

./b2 toolset=clang \
    cxxflags="${CXXFLAGS[*]}" \
    linkflags="${LINKFLAGS[*]}" \
    address-model=64 link=static runtime-link=static \
    --with-program_options --with-regex --with-date_time \
    --with-filesystem --with-thread --with-locale \
    --prefix="${PREFIX}" -j${JOBS} \
    install

# Copy the header and library files.

cp -R _build/include/boost/* "${OUTPUT}/Headers/boost"

for LIB in "${LIBS[@]}"; do
    cp _build/lib/"${LIB}" "${OUTPUT}/Libraries/${PLATFORM}"
done

#Build iOS

#./iOS_build_boost.sh  -ios --boost-version 1.75.0 --boost-libs "program_options regex date_time filesystem thread"

#cp -R dist/boost.xcframework "${OUTPUT}/Libraries/iOS"

# Return to source directory

cd "${SRCROOT}"
