# BaseElements-Plugin-Libraries

This is set of scripts and tools that are used to build the external libraries used in the BE plugin : https://github.com/GoyaPtyLtd/BaseElements-Plugin

At this stage, the only semi completed OS is the macOS one.  The linux examples are somewhat working, but do not follow the same structures as the mac one, so will need to be modified to work.  

#TODO 

1. Fix issue #1 which is around libde265 not compiling
2. Fix issue #2 which is about the proper compiling of the libheif library
3. Check the imageMagick compile uses all the libraries we've compiled and not others.
4. Build an rsync script to copy ( individually ) the output from here into the BE plugin folder, one at a time so we can test compiling the plugin on Mac.

If you're at all interested in the BE plugin and compiling code for it, or helping out, we'd love some assistance.
