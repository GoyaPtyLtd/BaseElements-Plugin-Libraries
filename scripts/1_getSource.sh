#!/bin/bash
# Downloads all source archives needed for building the libraries.
# Archives are downloaded to ../source/ directory.

set -e

# Source common build functionality (colors, helpers)
source "$(dirname "$0")/build/_build_common.sh"

# Check if wget is installed
if ! command -v wget &> /dev/null; then
    print_error "ERROR: wget is not installed. Please install it first:"
    echo "  Ubuntu: sudo apt install wget"
    echo "  macOS: brew install wget"
    exit 1
fi

# Get script directory and change to source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/../source" || {
    print_error "ERROR: Failed to change to source directory"
    exit 1
}

# Check if sha256sum is available (Linux) or shasum (macOS)
if command -v sha256sum >/dev/null 2>&1; then
    SHA256_CMD="sha256sum"
    SHA256_CHECK_CMD="sha256sum -c --quiet"
elif command -v shasum >/dev/null 2>&1; then
    SHA256_CMD="shasum -a 256"
    SHA256_CHECK_CMD="shasum -a 256 -c --quiet"
else
    SHA256_CMD=""
    SHA256_CHECK_CMD=""
fi

# Download function: name, version, count, url, filename
download() {
    local name="$1"
    local version="$2"
    local count="$3"
    local url="$4"
    local filename="$5"
    local max_retries=3
    local retry_delay=2
    local attempt=1
    
    print_info "Downloading ${name} ${version} (${count} of 25)..."
    rm -f "$filename"
    
    # Retry loop for downloads
    while [[ $attempt -le $max_retries ]]; do
        if [[ $attempt -gt 1 ]]; then
            print_info "  Retry attempt ${attempt} of ${max_retries} (waiting ${retry_delay}s)..."
            sleep $retry_delay
        fi
        
        # Use timeout to prevent wget from hanging indefinitely
        # --timeout=60: total timeout for the entire operation
        # --dns-timeout=10: DNS lookup timeout
        # --connect-timeout=10: connection timeout
        # --read-timeout=30: timeout for reading data
        # --tries=1: don't retry (we handle retries in the script)
        if wget -q --show-progress --timeout=60 --dns-timeout=10 --connect-timeout=10 --read-timeout=30 --tries=1 -O "$filename" "$url"; then
            # Download succeeded, break out of retry loop
            break
        fi
        
        # Download failed
        if [[ $attempt -eq $max_retries ]]; then
            # Last attempt failed
            print_error "ERROR: Failed to download ${name} after ${max_retries} attempts"
            echo "  URL: $url"
            echo "  Output: $filename"
            exit 1
        fi
        
        # Remove partial download before retry
        rm -f "$filename"
        attempt=$((attempt + 1))
    done
    
    # Verify SHA256 hash if SHA256SUMS file exists
    if [[ -f "SHA256SUMS" ]] && [[ -n "$SHA256_CHECK_CMD" ]]; then
        # Extract expected hash from SHA256SUMS for this file
        local expected_hash=$(grep -E "^[0-9a-f]{64}[[:space:]]+\./${filename}$" "SHA256SUMS" | awk '{print $1}')
        if [[ -z "$expected_hash" ]]; then
            # Hash missing from SHA256SUMS
            print_error "ERROR: Hash missing from SHA256SUMS for ${filename}"
            print_error "  The file ${filename} was downloaded but has no entry in SHA256SUMS"
            print_error "  This usually means the library version was updated but SHA256SUMS was not regenerated"
            print_info ""
            print_info "  To fix:"
            print_info "    1. Run: ./scripts/regenerate_sha256.sh"
            print_info "    2. Commit the updated source/SHA256SUMS file to the repository"
            exit 1
        fi
        
        # Hash exists, verify it matches
        local actual_hash=$($SHA256_CMD "$filename" | awk '{print $1}')
        if [[ "$actual_hash" != "$expected_hash" ]]; then
            # Hash mismatch
            print_error "ERROR: SHA256 hash mismatch for ${filename}"
            print_error "  Expected hash: ${expected_hash}"
            print_error "  Actual hash:   ${actual_hash}"
            print_error ""
            print_error "  This indicates:"
            print_error "    - File corruption during download, OR"
            print_error "    - Wrong file version downloaded, OR"
            print_error "    - SHA256SUMS contains incorrect hash"
            print_info ""
            print_info "  To fix:"
            print_info "    1. Re-download the file (it may be corrupted)"
            print_info "    2. If you updated the library version, run: ./scripts/regenerate_sha256.sh"
            print_info "    3. Commit the updated source/SHA256SUMS file to the repository"
            exit 1
        fi
        print_info "  ✓ SHA256 verified"
    fi
}

# Download all libraries
print_header "Starting download of 25 source archives..."
echo ""

download "Boost" "1.85.0" "1" "https://archives.boost.io/release/1.85.0/source/boost_1_85_0.tar.gz" "boost.tar.gz"
download "Curl" "8.7.1" "2" "https://curl.se/download/curl-8.7.1.tar.gz" "curl.tar.gz"
download "duktape" "2.7.0" "3" "https://duktape.org/duktape-2.7.0.tar.xz" "duktape.tar.xz"
download "expat" "2.6.2" "4" "https://github.com/libexpat/libexpat/releases/download/R_2_6_2/expat-2.6.2.tar.xz" "expat.tar.xz"
download "fontconfig" "2.15.0" "5" "https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.gz" "fontconfig.tar.gz"
download "freetype" "2.13.2" "6" "https://sourceforge.net/projects/freetype/files/freetype2/2.13.2/freetype-2.13.2.tar.gz" "freetype.tar.gz"
download "libiconv" "1.17" "7" "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz" "libiconv.tar.gz"
download "libde265" "1.0.16" "8" "https://github.com/strukturag/libde265/archive/refs/tags/v1.0.16.tar.gz" "libde265.tar.gz"
download "openjpeg" "2.5.2" "9" "https://github.com/uclouvain/openjpeg/archive/refs/tags/v2.5.2.tar.gz" "libopenjp2.tar.gz"
download "libheif" "1.17.6" "10" "https://github.com/strukturag/libheif/releases/download/v1.17.6/libheif-1.17.6.tar.gz" "libheif.tar.gz"
download "libjpeg" "v9f" "11" "http://ijg.org/files/jpegsrc.v9f.tar.gz" "libjpeg.tar.gz"
download "libjpeg-turbo" "3.0.3" "12" "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.3/libjpeg-turbo-3.0.3.tar.gz" "libturbojpeg.tar.gz"
download "ImageMagick" "7.1.1-29" "13" "https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.1-29.tar.gz" "ImageMagick.tar.gz"
download "jq" "1.7.1" "14" "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-1.7.1.tar.gz" "jq.tar.gz"
download "libssh2" "1.11.1" "15" "https://libssh2.org/download/libssh2-1.11.1.tar.gz" "libssh.tar.gz"
download "libxml2" "2.13.0" "16" "https://download.gnome.org/sources/libxml2/2.13/libxml2-2.13.0.tar.xz" "libxml.tar.xz"
download "libxslt" "1.1.42" "17" "https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.42.tar.xz" "libxslt.tar.xz"
download "openssl" "3.2.1" "18" "https://www.openssl.org/source/openssl-3.2.1.tar.gz" "openssl.tar.gz"
download "Poco" "1.14.2" "19" "https://github.com/pocoproject/poco/archive/refs/tags/poco-1.14.2-release.tar.gz" "poco.tar.gz"
download "libunistring" "1.2" "20" "https://ftp.gnu.org/gnu/libunistring/libunistring-1.2.tar.gz" "libunistring.tar.gz"
download "podofo" "0.9.8" "21" "https://ixpeering.dl.sourceforge.net/project/podofo/podofo/0.9.8/podofo-0.9.8.tar.gz" "podofo.tar.gz"
download "zlib" "1.3.1" "22" "https://www.zlib.net/zlib-1.3.1.tar.xz" "zlib.tar.xz"
download "libpng" "1.6.43" "23" "https://github.com/pnggroup/libpng/archive/refs/tags/v1.6.43.tar.gz" "libpng.tar.gz"
download "nghttp2" "1.62.1" "24" "https://github.com/nghttp2/nghttp2/releases/download/v1.62.1/nghttp2-1.62.1.tar.xz" "nghttp2.tar.xz"
download "FM Plugin SDK" "22.0.1.68" "25" "https://downloads.claris.com/DEVREL/sdk/fm_plugin_sdk_22.0.1.68.zip" "fm_plugin_sdk.zip"

echo ""
print_success "Downloading Complete - All 25 archives downloaded successfully!"
