# desktop
The full-featured laboratory environment used to compile the software.

# Version 3 preview
This iteration comes with versatile install scripts with overlays prior to instalations
Also created the cutest package manager see ```desktop/install.sh```

## prepare
Scripts to bootstrap a new system, create a disk image, and start cross-compilation from your current system.

## install
Scripts to fetch, compile, and install projects.
Example function:

    ins_foo() {
        at http://nice.site.com/any/foo-1.0.0.tar.xz &&
        oa
    }

A project is installed by defining functions whose names start with ins_.
Available macros:
- at <url>: extracts the project name and version from the URL.
- oa <args> obtain and all... o && cf <args> && mo && mi . 
- o: downloads the tarball and expands it to /tmp/club/src/<name>.
- cf <args>: detects autoconf, configure and meson configured by args ***NEW***
- mo <args>: builds objects (make, others).
- mi <args>: installs the project (make install, others).

Category files:
- base.sh: basic components
- win-lib.sh: graphical libraries
- win.sh: graphical applications
...

## the guide ( aprox. )

1. Create desktop/sys.img

       cd desktop/prepare
       ./disk.sh create

2. Mount/umount the disk

       ./disk.sh mount

3. Prepare the first components

       ./prepare.sh tools all

4. Enter the environment and use the install scripts

       ./join.sh
       cd /root/club/desktop

5. Set up files

       ./install.sh first all

6. Set up base, win-lib, and win components

       ./install.sh {base,win-lib} all
       
		Individual options
		***NEW***
		./install.sh base binutils (uses a sandbox to inspect/package/upload/install features)
		./install.sh base binutils package   (installs already built files)
		./install.sh base binutils once      (util to repeat sequences)
		./install.sh base binutils unsafe	(util to repeat sequences)
