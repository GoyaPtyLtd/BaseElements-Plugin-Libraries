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

SRCROOT=${PWD}
cd ../../Output
OUTPUT=${PWD}

# Remove old libraries and headers

LIBS=(
    libboost_atomic.a
    libboost_date_time.a
    libboost_filesystem.a
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
PREFIX=${PWD}/_build

# Build

./bootstrap.sh --with-toolset=clang --with-libraries="atomic,chrono,date_time,exception,filesystem,program_options,regex,system,thread"

CFLAGS=()
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

    mkdir _build_iOS
    mkdir _build_iOS_Sim
    PREFIX_iOS=${PWD}/_build_iOS
    PREFIX_iOS_Sim=${PWD}/_build_iOS_Sim

elif [[ $OS = 'Linux' ]]; then
    CFLAGS+=(
        -fPIC
    )
    CXXFLAGS+=(
        -fPIC
    )
fi

./b2 toolset=clang \
    cflags="${CFLAGS[*]}" \
    cxxflags="${CXXFLAGS[*]}" \
    linkflags="${LINKFLAGS[*]}" \
    address-model=64 link=static runtime-link=static \
    --with-atomic --with-chrono --with-date_time --with-exception \
    --with-filesystem --with-program_options --with-regex --with-system --with-thread  \
    --prefix="${PREFIX}" -j${JOBS} \
    install

# Copy the header and library files.

cp -R _build/include/boost/* "${OUTPUT}/Headers/boost"

for LIB in "${LIBS[@]}"; do
    cp _build/lib/"${LIB}" "${OUTPUT}/Libraries/${PLATFORM}"
done

#Build iOS

#cp -R dist/boost.xcframework "${OUTPUT}/Libraries/iOS"

# Return to source directory

cd "${SRCROOT}"
