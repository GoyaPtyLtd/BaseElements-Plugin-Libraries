# BaseElements-Plugin-Libraries

This is set of scripts and tools that are used to build the external libraries used in the BE plugin : https://github.com/GoyaPtyLtd/BaseElements-Plugin

You need to use this to build the libraries used in the BE plugin itself.  As of BE 5.1.0 the Headers and Libraries aren't included in the main repository, and they need to be built from here.

### Goals

The goal is to turn this into a single script for each FileMaker platform ( Mac, Windows, Ubuntu linux ) that builds the various open source libraries in a configuration that works in the BE Plugin. Each library can then be updated and copied along with it's dependencies into the main BE Plugin folder.

We're a fair way along with this, we have both Mac and Linux building from the same set of files.  The iOS builds should also be possible to do from here.

### TODO

1. Build ubuntu x86 and arm versions.
2. Add all the iOS build stuff to the mac scripts.
3. Build a Windows script library.

If you're at all interested in the BE plugin and compiling code for it, or helping out, we'd love some assistance.

### Getting Started

To start with, we recommend you fork the BaseElements-Plugin-Libraries repository to your own account so you can test and push changes into the fork instead of our main - that makes it easier to submit patches.  If you've done that, make sure to change the location of the repositories below.

Each of the different OS versions has it's own one off setup.

### macOS Setup

On the mac you compile for x86, arm and iOS all from the one place, so the compile scripts for mac will build macOS ( and iOS versions eventually, we're working on macOS only for now ).

You need to install **XCode** and the XCode command line tools - if you don't have the tools, then they'll be installed for you when you try to install brew below.

There are a bunch of open source tools required as well, to make things easier we recommend you install these with [brew](https://brew.sh). Open that link then follow the install instructions there. Once you've got brew and the xcode command line tools installed, run this command to install the extras you need :

    brew install autoconf automake cmake gettext git git-lfs gnu-tar libtool m4 pkg-config protobuf wget xz

Not all of these may be needed, this was we had last time we checked. You want to avoid using lots of brew libraries as the compile options may find those instead of the ones we've built into the scripts, but we do try to hard code to our specific library versions.

You should have FileMaker Pro and/or Server installed before starting to build anything - the plugin build process will copy the built plugin to the Pro Extensions folder ready to test.

It shouldn't matter where you put the local version of the repository, but we put it at ~/Documents/GitHub :

    cd ~
    mkdir Documents/GitHub
    cd Documents/GitHub

    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git
    git clone --depth 1 --branch development https://github.com/GoyaPtyLtd/BaseElements-Plugin.git

Then follow the Build Process below.

### Ubuntu Setup

There is some general setup for Ubuntu, but slight differences for Ubuntu 20 vs 22, and x86 vs arm.  These instructions assume you're starting from a clean iso install.  You may come across incompatibilities if you've modified or otherwise installed other packages.

First, update the OS and install FileMaker Server which is required for building the plugin, and is good to keep active for compatibility - if you try to install something incompatible, it will uninstall FMS, which is a sign not to go there.

    sudo apt update
    sudo apt upgrade
    sudo apt install zip

**For Ubuntu 20**

    wget https://downloads.claris.com/esd/fms_21.0.2.202_Ubuntu20_amd64.zip
    unzip fms_21.0.2.202_Ubuntu20_amd64.zip
    sudo apt install ./filemaker-server-21.0.2.202-amd64.deb

**For Ubuntu 22 x86**

    wget https://downloads.claris.com/esd/fms_21.0.2.202_Ubuntu22_amd64.zip
    unzip fms_21.0.2.202_Ubuntu22_amd64.zip
    sudo apt install ./filemaker-server-21.0.2.202-amd64.deb

**For Ubuntu 22 arm**

    wget https://downloads.claris.com/esd/fms_21.0.2.202_Ubuntu22_arm64.zip
    unzip fms_21.0.2.202_Ubuntu22_arm64.zip
    sudo apt install ./filemaker-server-21.0.2.202-arm64.deb

Install development software :

    sudo apt install build-essential gperf cmake git git-lfs
    sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" llvm.sh 18
    sudo apt install libc++-18-dev libc++1-18 libc++abi-18-dev libc++abi1-18

Grab the repos from GitHub :

    cd ~
    mkdir source
    cd source
    git clone https://github.com/GoyaPtyLtd/BaseElements-Plugin-Libraries.git
    git clone --depth 1 --branch development https://github.com/GoyaPtyLtd/BaseElements-Plugin.git

As a one off, you need to reconfigure clang so that the command line tools can find the correct binaries.  We've provided a script to do this automatically for clang-18.

    cd ~/source/BaseElements-Plugin-Libraries/scripts/install
    sudo ./update-alternatives-clang.sh

Then follow the Build Process below.

### Build Process

Then switch to the Scripts folder as the base from which to call various compile scripts.

    cd ~/source/BaseElements-Plugin-Libraries/scripts
or
    cd ~/Documents/GitHub/BaseElements-Plugin-Libraries/scripts

Then run the script that downloads all the current source files :

    ./1_getSource.sh

You don't need to re-run this unless a linked version changes in github because there's a new version of one of the libraries. Each build process starts from a clean folder and unpacks the archive at the beginning, so you only need to download once. You can then run any of the individual **build** scripts, or build everything :

    ./2_build.sh

That will then run through every single build process and will take hours on most macs, seems to be only minutes on linux.

Once that is done, assuming no errors, all the required headers and libraries will be in the correct Plugin folder, so you can can then go to the BE plugin repository and build that.

### Updating to a new library version.

So for example, there's a new version of libcurl that you want to build and test for.  The steps would be :

* Modify the **1_getSource.sh** script to reference the new download.
* Change to the **script** directory.
* Run the **0_cleanOutputFolder.sh** if you've done builds before and it's not a clean clone.
* Run the **1_getSource.sh** script to download your new version.
* Run the **2_build.sh.sh** script and fix any issues that come up.
* Switch to xCode and compile the plugin.  Fix any newly introduced errors.
* Run FileMaker Pro or FileMaker Server with the new plugin, and run the BaseElements Plugin Tests.fmp12 file and run all the relevant tests.
* Submit a pull request for the changes to the library, we'll probably run the same tests and then incorporate them into the development branch for the next build.

### Windows Setup

TODO
