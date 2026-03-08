# desktop
The full-featured laboratory environment used to compile the software.

## prepare
Scripts to bootstrap a new system, create a disk image, and start cross-compilation from your current system.

## install
Scripts to fetch, compile, and install projects.

Example function:

    ins_foo() {
        at http://nice.site.com/any/foo-1.0.0.tar.xz && $r
        return $?
    }

A project is installed by defining functions whose names start with ins_.

Available macros:

- at <url>: extracts the project name and version from the URL.
- o: downloads the tarball and expands it to /tmp/club/src/<name>.
- cf <args>: runs ./configure.
- mo <args>: builds objects (make).
- mi <args>: installs the project (make install).
- oa <args>: ideal sequence: obtain, configure, build, install.
- $r <args>: regular install, expands to "oa".

Category files:

- base.sh: basic components
- win-lib.sh: graphical libraries
- win.sh: graphical applications

## develop/<name>
Convention used to modify projects from source and generate patches.
The obtain process will use development projects when available.
Patches located under desktop/patch/<name>-<ver>-<...>.patch are applied after expanding a matching project tarball.

## the guide

1. Create desktop/sys.img

       cd desktop/prepare
       ./disk.sh create

2. Mount/umount the disk

       ./disk.sh mount

3. Prepare the first components

       ./prepare.sh tools all

4. Enter the environment and use the install scripts

       ./join.sh
       cd /root/club/desktop/install

5. Set up files

       ./first.sh all

6. Set up base, win-lib, and win components

       ./{base,win-lib,win}.sh all
