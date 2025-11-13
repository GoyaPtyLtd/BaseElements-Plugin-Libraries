# BaseElements-Plugin-Libraries

Build scripts for compiling external libraries used by the [BaseElements Plugin](https://github.com/GoyaPtyLtd/BaseElements-Plugin). These scripts download sources, build each dependency, and consolidate everything into a single `external/` directory inside the plugin repo.

## Releases

For automated multi-platform builds, see `RELEASES.md`.

## Platform Status

- Ubuntu 24.04 (ARM/x86) – Working  
- macOS – Untested but close  
- Windows – Not supported

## Build Scripts

### 0_cleanOutputFolder.sh

Resets the output directory for the current platform:

- Deletes `output/platforms/{PLATFORM}/`
- Recreates `include/`, `lib/`, `src/`, and on macOS `frameworks/`

Run:

    ./0_cleanOutputFolder.sh

### 1_getSource.sh

Downloads and verifies all source archives into `source/`:

- Verifies SHA256 checksums from `source/SHA256SUMS`
- Only needed when versions change
- To change versions, edit URLs/filenames in the script
- After changing versions, regenerate checksums:

    ./scripts/regenerate_sha256.sh

Run:

    ./1_getSource.sh

### 2_build.sh

Builds libraries for the detected platform:

- Uses clang for consistent cross-platform output  
- Outputs to `output/platforms/{PLATFORM}/`  
- Cleans each library’s output before building  
- Supports building all or selected libraries

Run:

    ./2_build.sh --build all
    ./2_build.sh --build jq boost duktape

Flags:

- `--build` / `-b` – Select libraries or `all`  
- `--interactive` / `-i` – Prompt before each step

Libraries: `jq`, `duktape`, `curl`, `font`, `image`, `xml`, `boost`, `podofo`, `fm_plugin_sdk`, `all`.

### 3_copy.sh

Copies built output into the BaseElements-Plugin repo under `external/{PLATFORM}/`:

- Libraries → `lib/`
- Headers → `include/`
- Selected source (e.g. duktape) → `src/`
- FileMaker PlugInSDK if present

Requires `.env` in the repo root:

    PLUGIN_ROOT=/path/to/BaseElements-Plugin

Run:

    ./3_copy.sh

### 4_package.sh

Packages the same files used by `3_copy.sh` into:

- `external-{PLATFORM}.tar.gz`
- `external-{PLATFORM}.tar.gz.sha256`

Outputs to `output/platforms/`.

Run:

    ./4_package.sh

## Utility Scripts

### regenerate_sha256.sh

Rebuilds `SHA256SUMS` for all archives in `source/`.

Run:

    ./scripts/regenerate_sha256.sh

Use after adding or updating library sources, then commit the updated `SHA256SUMS`.

## Setup Instructions

### Ubuntu 24.04

Ubuntu 24.04 includes LLVM/Clang 18, which works well for this project.

Install dependencies:

    sudo apt update
    sudo apt upgrade
    sudo apt install build-essential zip gperf cmake git git-lfs \
        libc++-dev libc++abi-dev libexpat1-dev lld lldb liblldb-dev \
        libomp5 libomp-dev llvm llvm-dev llvm-runtime clang clangd \
        clang-format clang-tidy clang-tools libclang-dev libclang1 python3-clang

Clone and configure:

    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git
    cd BaseElements-Plugin-Libraries
    cp env.example .env
    # Edit .env and set PLUGIN_ROOT to your BaseElements-Plugin path

Build:

    cd scripts
    ./0_cleanOutputFolder.sh
    ./1_getSource.sh
    ./2_build.sh --build all
    ./3_copy.sh

### Ubuntu 22.04

Install LLVM 18:

    sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" llvm.sh 18

Configure clang alternatives:

    cd scripts/install
    sudo ./update-alternatives-clang.sh

Then follow the same dependency install and build steps as Ubuntu 24.04.

### macOS

Install Xcode command line tools:

    xcode-select --install

Install Homebrew and dependencies:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install autoconf automake bash cmake gettext git git-lfs gnu-tar \
        libtool m4 pkg-config protobuf wget xz

Clone and configure:

    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git
    cd BaseElements-Plugin-Libraries
    cp env.example .env
    # Set PLUGIN_ROOT to your BaseElements-Plugin path

Build:

    cd scripts
    ./0_cleanOutputFolder.sh
    ./1_getSource.sh
    ./2_build.sh --build all
    ./3_copy.sh

### Windows

Windows builds are not currently supported. Contributions welcome.