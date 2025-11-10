# BaseElements-Plugin-Libraries

Build scripts and tools for compiling external libraries used in the [BaseElements Plugin](https://github.com/GoyaPtyLtd/BaseElements-Plugin). This repository builds dependencies like Boost, curl, jq, ImageMagick, and others, then copies all compiled libraries, headers, and selected source files into a consolidated `./external/` directory in the BaseElements-Plugin repository.

## Platform Support

- **Ubuntu 24 (ARM/x86)** - Working
- **macOS** - Untested, Probably almost working
- **Windows** - Not built

## Build Scripts

The build process consists of numbered scripts that must be run in sequence:

### Script 0: `0_cleanOutputFolder.sh`

Cleans the output directory for the current platform, removing all previously built libraries and creating a fresh directory structure.

**What it does:**
- Removes `output/platforms/{PLATFORM}/` directory
- Creates fresh `include/`, `lib/`, and `src/` directories
- On macOS, also creates `frameworks/` directory

**Usage:**
```bash
./0_cleanOutputFolder.sh
```

**Flags:**
- Platform detection is automatic (no flags needed)

### Script 1: `1_getSource.sh`

Downloads all source archives needed for building the libraries.

**What it does:**
- Downloads source archives for all dependencies (Boost, curl, jq, duktape, ImageMagick, etc.)
- Saves archives to `../source/` directory
- **Verifies SHA256 hashes** against `source/SHA256SUMS` after each download to ensure file integrity
- Only needs to be run once or when library versions change

**SHA256 Verification:**
The script automatically verifies each downloaded file against the `source/SHA256SUMS` file. This ensures:
- Files are not corrupted during download
- Files match the expected versions
- Security (detects tampering or incorrect downloads)

If verification fails, the script will exit with an error message. If you've updated a library version, you'll need to regenerate `SHA256SUMS` (see below).

**Customizing versions or sources:**
To test different library versions or source from alternate locations (e.g., forks, development branches, or local mirrors), edit `1_getSource.sh` and modify the `download` function calls. Each call takes 5 parameters:
- Library name (display only)
- Version string (display only)
- Count number (display only)
- **URL** - Change this to download from a different source or version
- **Filename** - The local filename to save as

Example: To test a newer curl version or a fork:
```bash
download "Curl" "8.7.0" "2" "https://github.com/yourfork/curl/archive/refs/tags/curl-8.7.0.tar.gz" "curl.tar.gz"
```

**Important:** When updating library versions, you must regenerate the `SHA256SUMS` file:
```bash
./source/regenerate_sha256.sh
```
Then commit the updated `source/SHA256SUMS` file to the repository.

You can also use local file paths or custom URLs for development/testing purposes.

**Usage:**
```bash
./1_getSource.sh
```

**Flags:**
- No flags needed

### Script 2: `2_build.sh`

Builds the libraries from source. Can build all libraries or specific ones.

**What it does:**
- Compiles libraries for the detected platform
- Places built libraries in `output/platforms/{PLATFORM}/lib/`
- Places headers in `output/platforms/{PLATFORM}/include/`
- Uses clang on Linux (not GCC) for cross platform consistency
- Each library build completely cleans its output directories (`lib/`, `include/`, `src/`) and builds 100% fresh each time
- Most libraries depend on each other and must be built in order (e.g., `curl` requires `zlib`, `openssl`, `libssh2`, and `nghttp2` to be built first). The script will detect and exit if dependencies are missing.



**Usage:**
```bash
# Build all libraries
./2_build.sh --build all

# Build specific libraries
./2_build.sh --build jq
./2_build.sh --build boost jq duktape

# Interactive mode (prompts before each step)
./2_build.sh --build all --interactive
```

**Flags:**
- `--build`, `-b` - Specify library names to build (or "all")
- `--interactive`, `-i` - Enable interactive mode (prompt before each build step)

**Available libraries:** `all`, `jq`, `duktape`, `curl`, `font`, `image`, `xml`, `boost`, `podofo`

### Script 3: `3_copy.sh`

Copies all built libraries, headers, and selected source files from the output directory into a single consolidated location in the BaseElements-Plugin repository.

**What it does:**
- Copies all compiled libraries to `BaseElements-Plugin/external/{PLATFORM}/lib/`
- Copies all headers to `BaseElements-Plugin/external/{PLATFORM}/include/`
- Copies selected source files (e.g., duktape) to `BaseElements-Plugin/external/{PLATFORM}/src/`
- Removes and recreates the platform-specific directory on each run to ensure a clean state
- Platform names: `macos-arm64-x86_64`, `ubuntu20.04-x86_64`, `ubuntu20.04-aarch64`, `ubuntu22.04-x86_64`, `ubuntu22.04-aarch64`, `ubuntu24.04-x86_64`, `ubuntu24.04-aarch64`
- Requires `PLUGIN_ROOT` to be set in `.env` file

**Usage:**
```bash
# Copy all libraries, headers, and source files
./3_copy.sh

# Interactive mode (prompts before each step)
./3_copy.sh --interactive
```

**Flags:**
- `--interactive`, `-i` - Enable interactive mode (prompt before each copy step)

**Requirements:**
- `.env` file in project root with `PLUGIN_ROOT=/path/to/BaseElements-Plugin`

**Note:** This refactored approach consolidates all external libraries into a single `./external/` directory structure, making it simpler to import and reference libraries. The CMake configuration in BaseElements-Plugin will need to be updated to reference the new `./external/` location instead of the previous distributed structure.

**Using `.env` for multiple repository management:**
The `.env` file is particularly useful for managing multiple copies of this repository, each tracking different library versions. You can maintain separate clones of BaseElements-Plugin-Libraries (e.g., one for testing new library versions, another for stable releases) and configure each `.env` file to point to different BaseElements-Plugin repositories or branches. This allows you to test library updates in isolation before merging into your main development branch.

## Utility Scripts

### `generate_sha256.sh`

Generates SHA256 hashes for all source archives in the `source/` directory.

**What it does:**
- Scans the `source/` directory for all archive files (`.tar.gz`, `.tar.xz`)
- Computes SHA256 hash for each file
- Writes all hashes to `source/SHA256SUMS` in standard format
- Sorts the output by filename for consistency

**Usage:**
```bash
./scripts/generate_sha256.sh
```

**When to use:**
- After downloading new source archives
- After updating library versions in `1_getSource.sh`
- To regenerate hashes if `SHA256SUMS` is missing or outdated

**Important:** Always commit the updated `source/SHA256SUMS` file to the repository after regenerating it. This ensures all users can verify their downloads match the expected files.

## Setup Instructions

### Ubuntu 24.04 (ARM/x86)

**Note:** Ubuntu 24.04 defaults to LLVM/Clang v18, which is ideal for this project and tracks closely to macOS 15 & 26 clang version 17. See: https://documentation.ubuntu.com/ubuntu-for-developers/reference/availability/llvm/

**Alternative:** You can also follow the Ubuntu 22.04 steps in the "Other Ubuntu Versions" section below if you prefer to track one consistent approach (e.g., when using Ansible or GitHub runners to build). 

**1. Update system and install dependencies:**
```bash
sudo apt update
sudo apt upgrade
sudo apt install \
    build-essential \
    gperf \
    cmake \
    git \
    git-lfs \
    libc++-dev \
    libc++abi-dev \
    libexpat1-dev \
    lld \
    lldb \
    liblldb-dev \
    libomp5 \
    libomp-dev \
    llvm \
    llvm-dev \
    llvm-runtime \
    libllvm-ocaml-dev \
    clang \
    clangd \
    clang-format \
    clang-tidy \
    clang-tools \
    libclang-dev \
    libclang1 \
    python3-clang
```



**2. Clone repositories:**
```bash
cd ~
mkdir -p source
cd source
git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git
```

**3 Configure PLUGIN_ROOT:**
```bash
cd BaseElements-Plugin-Libraries
cp env.example .env
# Edit .env and set PLUGIN_ROOT to your BaseElements-Plugin path
# Example: PLUGIN_ROOT=/home/daniel/source/BaseElements-Plugin
```

**4. Run build process:**
```bash
cd scripts
./0_cleanOutputFolder.sh
./1_getSource.sh
./2_build.sh --build all
./3_copy.sh
```

### Other Ubuntu Versions

If building on Ubuntu 22.04 you will need to manually install LLVM 18:

**1. Install LLVM 18:**
```bash
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" llvm.sh 18
```

**2. Follow step 1 from the Ubuntu 24.04 section above** (update system and install dependencies).

**3. Configure clang:**
```bash
cd ~/source/BaseElements-Plugin-Libraries/scripts/install
sudo ./update-alternatives-clang.sh
```

**4. Follow steps 2-4 from the Ubuntu 24.04 section above** (clone repositories, configure PLUGIN_ROOT, and run build process).

### macOS

**1. Install command line tools:**
```bash
# Install Xcode command line tools (no App Store required):
xcode-select --install
```

**2. Install Homebrew and dependencies:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install autoconf automake bash cmake gettext git git-lfs gnu-tar \
    libtool m4 pkg-config protobuf wget xz
```

**Note:** The command line tools are sufficient for building. If you need the full Xcode IDE, install it from the App Store or use `brew install xcodes` to manage Xcode versions.

**3. Clone repositories:**
```bash
cd ~
git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git
```

**4. Configure PLUGIN_ROOT:**
```bash
cd BaseElements-Plugin-Libraries
cp env.example .env
# Edit .env and set PLUGIN_ROOT to your BaseElements-Plugin path
# Example: PLUGIN_ROOT=/Users/username/BaseElements-Plugin
```

**5. Run build process:**
```bash
cd scripts
./0_cleanOutputFolder.sh
./1_getSource.sh
./2_build.sh --build all
./3_copy.sh
```

### Windows

Windows builds are not currently supported. Contributions welcome!
