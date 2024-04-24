#BaseElements-Plugin-Libraries

This is set of scripts and tools that are used to build the external libraries used in the BE plugin : https://github.com/GoyaPtyLtd/BaseElements-Plugin

At this stage, the only semi completed OS is the macOS one.  

The iOS examples are structured the correct way to match how the mac ones are done, but at this stage are incomplete and untested - they probably contain a lot of typos.  

###TODO 

1. Fix issue #1 which is around libde265 not compiling
2. Fix issue #2 which is about the proper compiling of the libheif library
3. Check the imageMagick compile uses all the libraries we've compiled and not others.
4. Build an rsync script to copy ( individually ) the output from here into the BE plugin folder, one at a time so we can test compiling the plugin on Mac.

If you're at all interested in the BE plugin and compiling code for it, or helping out, we'd love some assistance.


###macOS Setup

On the mac you compile for x86, arm and iOS all from the one place, but the compile scripts are separate for macOS and iOS at the moment.  

You need to install XCode and the XCode command line tools.  There are a bunch of open source tools required as well, to make things easier we recommend you install these with brew : https://brew.sh  Open that link then follow the install instructions there.  Our set of installed tools are :

`brew install automake gettext gnu-tar libtool protobuf autoconf git wget autoconf-archive cmake git-lfs m4 pkg-config xz`

Not all of these may be needed, this was we had last time we checked.  You want to avoid using lots of brew libraries as the compile options may find those instead of the ones we've built into the scripts.

###Getting Started

To start with, we recommend you fork the BaseElements-Plugin-Libraries repository to your own account so you can test and push changes into the fork instead of our main - that makes it easier to submit patches.

Once you've pulled down the code from gitHub then you :

`cd BaseElements-Plugin-Libraries/Scripts
chmod +x _getSource.sh
chmod +x macOS_build*
./_getSource.sh`

That last step pulls down all the latest source code into the source folder ready for you to start compiling.  Each of the individual .sh docs can be run by themselves, or can have their code copied out of for testing steps.  They should be self contained, and when run should clear everything out and start fresh.