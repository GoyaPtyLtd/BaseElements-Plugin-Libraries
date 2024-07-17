# BaseElements-Plugin-Libraries

This is set of scripts and tools that are used to build the external libraries used in the BE plugin : https://github.com/GoyaPtyLtd/BaseElements-Plugin

If you want to compile the BE plugin, then you don't need this, the current main build of the BE plugin should compile as is on latest macOS at least. Working with this library is only to build newer versions of the open source libraries used in the BE Plugin. If you're experienced in shell scripting, or in compiling open source tools, then we'd love some help with this project.

### Goals

The goal is to turn this into a single script for each FileMaker platform ( Mac, Windows, Ubuntu linux ) that builds the various open source libraries in a configuration that works in the BE Plugin. Each library can then be updated and copied along with it's dependencies into the main BE Plugin folder

### TODO

1. Build ubuntu x86 and arm versions.
2. Add all the iOS build stuff to the mac scripts.
3. Build a Windows script library.

If you're at all interested in the BE plugin and compiling code for it, or helping out, we'd love some assistance.

### Getting Started

To start with, we recommend you fork the BaseElements-Plugin-Libraries repository to your own account so you can test and push changes into the fork instead of our main - that makes it easier to submit patches.

Each of the different OS versions has it's own Setup routine, that is a one off.

### macOS Setup

On the mac you compile for x86, arm and iOS all from the one place, so the compile scripts for mac will build both macOS and iOS versions ( eventually, we're working on macOS only for now ).

You need to install **XCode** and the XCode command line tools.

There are a bunch of open source tools required as well, to make things easier we recommend you install these with [brew](https://brew.sh). Open that link then follow the install instructions there. Our set of installed tools are :

    brew install autoconf automake cmake gettext git git-lfs gnu-tar libtool m4 pkg-config protobuf wget xz

Not all of these may be needed, this was we had last time we checked. You want to avoid using lots of brew libraries as the compile options may find those instead of the ones we've built into the scripts.

You also need to configure git with git-lfs :

    git lfs install

It shouldn't matter where you put the local version of the repository, but we put it at ~/Documents/GitHub :

    cd ~
    mkdir Documents/GitHub
    cd Documents/GitHub

    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git

If you're compiling the plugin you may also need to clone that, and because it's large you'll need to use ssh to clone it :

    git clone git@github.com:GoyaPtyLtd/BaseElements-Plugin.git

If you don't have ssh setup for git, instructions are here : [https://phoenixnap.com/kb/git-clone-ssh](https://phoenixnap.com/kb/git-clone-ssh)

Then switch to the Scripts folder as the base from which to call various compile scripts.

    cd BaseElements-Plugin-Libraries/scripts

Then run the script that downloads all the current source files :

    ./1_getSource.sh

You don't need to re-run this unless it changes in github and there's a new version of one of the libraries. Each build process starts from a clean folder and unpacks the archive at the beginning, so you only need to download once. You can then run any of the individual **build** scripts, or build everything :

    ./2_build.sh
    
That will then run through every single build process and will take hours on most macs.

### Updating to a new library version.

So for example, there's a new version of libcurl that you want to build and test for.  The steps would be :

* Pull down the git repos for both the library and the plugin as above.
* Check that the BE plugin compiles successfully.
* If you've previously run any scripts, clear things out by running the **_cleanOutputFolder.sh** script.
* Modify the **1_getSource.sh** script to reference the new download.
* Run the **1_getSource.sh** script to download your new version.
* change to the **build** directory.
* Run the **build_curl_0_all.sh** script, or run each individual curl build scripts in turn.
* Once all the parts are compiling, then switch to the **copy** folder, and run the **copy_curl.sh** script.
* Switch to xCode and attempt to compile the plugin.  Fix any newly introduced errors.
* Run FileMaker Pro or FileMaker Server with the new plugin, and run the BaseElements Plugin Tests.fmp12 file and run all the relevant tests.
* Submit a pull request for the changes to the library, we'll probably run the same tests and then incorporate them into the main 

### Ubuntu Setup

Just documenting this here as none of the ubuntu script are tested yet.

    sudo apt update
    sudo apt install git-all git-lfs codeblocks
    sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
    sudo apt install make cmake gperf clang-format clang-tidy clang-tools clang clangd libc++-dev libc++abi-dev \
        libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev \
        llvm-runtime llvm python3-clang g++ gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

    sudo mkdir /opt/FileMaker
    sudo chown "${USER:=$(/usr/bin/id -run)}:$USER" /opt/FileMaker

    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git

We run codeblocks via sudo as it usually means that it can find the various libraries it needs easier. If there's a better way to do that, then that would be good :)

### Windows Setup

TODO
