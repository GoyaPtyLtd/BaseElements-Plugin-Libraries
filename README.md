# BaseElements-Plugin-Libraries

Build scripts and tools for compiling external libraries used in the [BaseElements Plugin](https://github.com/GoyaPtyLtd/BaseElements-Plugin). This repository builds dependencies like Boost, curl, jq, ImageMagick, and others, then copies the compiled libraries and headers into the BaseElements-Plugin repository structure.

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
- Only needs to be run once or when library versions change

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

Copies built libraries and headers from the output directory into the BaseElements-Plugin repository.

**What it does:**
- Copies compiled libraries to `BaseElements-Plugin/Libraries/{PLATFORM}/`
- Copies headers to `BaseElements-Plugin/Headers/`
- Copies source files to `BaseElements-Plugin/Source/` (where needed)
- Requires `PLUGIN_ROOT` environment variable or `.env` file

**Usage:**
```bash
# Copy all libraries
./3_copy.sh --copy all

# Copy specific libraries
./3_copy.sh --copy jq
./3_copy.sh --copy boost jq curl

# Interactive mode
./3_copy.sh --copy all --interactive
```

**Flags:**
- `--copy`, `-c` - Specify library names to copy (or "all")
- `--interactive`, `-i` - Enable interactive mode (prompt before each copy step)

**Available libraries:** `all`, `boost`, `curl`, `duktape`, `font`, `headers`, `image`, `jq`, `xml`

**Requirements:**
- `PLUGIN_ROOT` environment variable set, or
- `.env` file in project root with `PLUGIN_ROOT=/path/to/BaseElements-Plugin`

## Setup Instructions

### Ubuntu 24.04 (ARM/x86)

**1. Update system and install dependencies:**
```bash
sudo apt update
sudo apt upgrade
sudo apt install build-essential gperf cmake git git-lfs wget zip
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" llvm.sh 18
```

**2. Configure clang:**
```bash
cd ~/source/BaseElements-Plugin-Libraries/scripts/install
sudo ./update-alternatives-clang.sh
```

**3. Clone repositories:**
```bash
cd ~
mkdir -p source
cd source
git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git
```

**4. Configure PLUGIN_ROOT:**
```bash
cd BaseElements-Plugin-Libraries
cp env.example .env
# Edit .env and set PLUGIN_ROOT to your BaseElements-Plugin path
# Example: PLUGIN_ROOT=/home/daniel/source/BaseElements-Plugin
```

**5. Run build process:**
```bash
cd scripts
./0_cleanOutputFolder.sh
./1_getSource.sh
./2_build.sh --build all
./3_copy.sh --copy all
```

### macOS

**1. Install Xcode and command line tools:**
```bash
# Install Xcode from App Store, then:
xcode-select --install
```

**2. Install Homebrew and dependencies:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install autoconf automake bash cmake gettext git git-lfs gnu-tar libtool m4 pkg-config protobuf wget xz
```

**3. Clone repositories:**
```bash
cd ~
mkdir -p Documents/GitHub
cd Documents/GitHub
git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git
```

**4. Configure PLUGIN_ROOT:**
```bash
cd BaseElements-Plugin-Libraries
cp env.example .env
# Edit .env and set PLUGIN_ROOT to your BaseElements-Plugin path
# Example: PLUGIN_ROOT=/Users/username/Documents/GitHub/BaseElements-Plugin
```

**5. Run build process:**
```bash
cd scripts
./0_cleanOutputFolder.sh
./1_getSource.sh
./2_build.sh --build all
./3_copy.sh --copy all
```

### Windows

Windows builds are not currently supported. Contributions welcome!
