# Basic programs

ins_binutils() {
    at_desc "Translating code into something the machine won't immediately reject"
    at_gnu 2.44 &&
    wbd && oc \
        --sysconfdir=/etc \
        --enable-gold \
        --enable-ld=default \
        --enable-plugins \
        --enable-shared \
        --disable-werror \
        --enable-64-bit-bfd \
        --enable-new-dtags \
        --with-system-zlib \
        --enable-multilib \
        --enable-default-hash-style=gnu &&
    make tooldir=/usr && make tooldir=/usr install &&
    rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a
}

ins_coreutils() {
    at_desc "The commands you thought were built into the terminal but aren't"
    at_gnu 9.5 &&
    oa --enable-install-program=hostname &&
    mo NON_ROOT_USERNAME=nobody -k check &&
    mi
}

ins_kbd() {
    at_desc "Because smashing keys should actually produce characters"
    at https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-2.8.0.tar.gz &&
    o &&
    sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure &&
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in &&
    ca --disable-vlock
}

ins_bash() {
    at_desc "The shell that silently judges your typos"
    at_gnu 5.3 &&
    oa --without-bash-malloc --with-installed-readline
}

ins_file() {
    at_desc "Telling you it's a 'text file' when you just wanted to read it"
    at http://ftp.astron.com/pub/file/file-5.46.tar.gz &&
    oa && a32 --libdir=/usr/lib32 --host=i686-pc-linux-gnu
}

ins_readline() {
    at_desc "Allowing you to press up-arrow to repeat your mistakes"
    at_gnu 8.2 &&
    o && bd &&
    sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf &&
    cf --disable-static --with-curses &&
    LIBS="-lncursesw" mo SHLIB_LIBS="-lncursesw" && mi &&
    a32 --disable-static --with-curses && mo32 && mi32
}

ins_which() {
    at_desc "Finding exactly where you hid that binary"
    at "https://ftpmirror.gnu.org/which/which-2.23.tar.gz" &&
    oa
}

ins_attr() {
    at_desc "Giving your files a secret personality and extended attributes"
    at https://download-mirror.savannah.gnu.org/releases/attr/attr-2.5.2.tar.xz &&
    oa --disable-static --sysconfdir=/etc && make distclean && r32
}

ins_acl() {
    at_desc "Micromanaging who gets to look at your stuff"
    at https://download-mirror.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz &&
    oa --disable-static && a32 --libdir=/usr/lib32 --libexecdir=/usr/lib32 --host=i686-club-linux-gnu
}

ins_bc() {
    at_desc "A calculator for when you are too lazy to open your phone"
    at https://github.com/gavinhoward/bc/releases/download/7.0.3/bc-7.0.3.tar.xz &&
    o && CC='gcc -std=c99' ca
}

ins_gawk() {
    at_desc "Slicing text like a grumpy ninja"
    at_gnu 5.3.2 &&
    oa
}

ins_findutils() {
    at_desc "Looking for needles in a filesystem haystack"
    at_gnu findutils 4.10.0 tar.xz &&
    oa --localstatedir=/var/lib/locate
}

ins_sudo() {
    at_desc "The 'Simon Says' of the Linux world"
    at https://www.sudo.ws/dist/sudo-1.9.17p2.tar.gz &&
    oa --libexecdir=/usr/lib --prefix=/usr --build=x86_64-club-linux-gnu --disable-pam-session --without-pam
}

ins_vim() {
    at_desc "The text editor you can't exit"
    at https://github.com/vim/vim/archive/refs/tags/v9.1.1831.tar.gz 9.1.1831 tar.gz &&
    oa
}

ins_sed() {
    at_desc "Find and replace on steroids"
    at_gnu 4.9 &&
    oa
}

ins_grep() {
    at_desc "Staring into the text abyss until it stares back"
    at_gnu 3.12 &&
    oa
}

ins_groff() {
    at_desc "Formatting text like it's 1989"
    at_gnu 1.23.0 &&
    PAGE=A4 oa
}

ins_expat() {
    at_desc "Parsing XML so you don't have to suffer directly"
    at https://github.com/libexpat/libexpat/releases/download/R_2_7_3/expat-2.7.3.tar.xz &&
    $ru && make distclean && r32 --disable-static
}

ins_less() {
    at_desc "Because sometimes 'more' is just too much"
    at http://www.greenwoodsoftware.com/less/less-679.tar.gz &&
    oa --prefix=/usr --sysconfdir=/etc
}

ins_shadow() {
    at_desc "Hiding your terrible passwords since forever"
    at https://github.com/shadow-maint/shadow/releases/download/4.16.0/shadow-4.16.0.tar.xz &&
    oa --sysconfdir=/etc \
        --disable-static \
        --without-libbsd \
        --without-libpam \
        --with-{b,yes}crypt
}

ins_psmisc() {
    at_desc "Killing processes with extreme prejudice"
    at https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.7.tar.xz &&
    oa
}

ins_procps_ng() {
    at_desc "Spying on what your CPU is actually doing"
    src="procps"
    at https://gitlab.com/procps-ng/procps/-/archive/v4.0.6/procps-v4.0.6.tar.gz v4.0.6 && 
    oa \
        --docdir=/usr/share/doc/procps-ng-4.0.5 \
        --build=x86_64-club-linux-gnu \
        --disable-static \
        --disable-kill \
        --enable-watch8bit
}

# Compression

ins_tar() {
    at_desc "Smashing files together and hoping they don't break"
    at_gnu 1.35 && 
    FORCE_UNSAFE_CONFIGURE=1 oa
}

ins_bzip2() {
    at_desc "Making files smaller but taking its sweet time"
    at https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz &&
    o &&
    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile &&
    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile &&
    make -f Makefile-libbz2_so &&
    make clean &&
    mia="PREFIX=/usr" &&
    mo && mi && 
    cp -av libbz2.so.* /usr/lib &&
    ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so &&
    cp -v bzip2-shared /usr/bin/bzip2 &&
    for i in /usr/bin/{bzcat,bunzip2}; do ln -sfv bzip2 $i; done &&
    rm -fv /usr/lib/libbz2.a
}

ins_bzip232() {
    at_desc "Bzip2, but make it retro (32-bit)"
    project="bzip2"
    at https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz &&
    o &&
    sed -e "s/^CC=.*/CC=gcc -m32/" -i Makefile{,-libbz2_so} &&
    make -f Makefile-libbz2_so &&
    make libbz2.a &&
    install -Dm755 libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0.8 &&
    ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so &&
    ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1 &&
    ln -sf libbz2.so.1.0.8 /usr/lib32/libbz2.so.1.0 &&
    install -Dm644 libbz2.a /usr/lib32/libbz2.a &&
    di
}

ins_xz() {
    at_desc "Squishing files so small they practically disappear"
    at https://github.com/tukaani-project/xz/releases/download/v5.6.2/xz-5.6.2.tar.gz &&
    oa && a32
}

ins_lz4() {
    at_desc "Compressing stuff faster than you can blink"
    at https://github.com/lz4/lz4/releases/download/v1.10.0/lz4-1.10.0.tar.gz &&
    local fl="BUILD_STATIC=no PREFIX=/usr" &&
    o && mo $fl && mi $fl && 
    make clean &&
    mo32 $fl && mi32n $fl
}

ins_zstd() {
    at_desc "The compression algorithm that makes the others jealous"
    at https://github.com/facebook/zstd/releases/download/v1.5.6/zstd-1.5.6.tar.gz &&
    o && mo prefix=/usr && mi prefix=/usr && rm -v /usr/lib/libzstd.a &&
    make clean && mo32 prefix=usr && mi32n prefix=/usr &&
    sed -e "/^libdir/s/lib$/lib32/" -i /usr/lib32/pkgconfig/libzstd.pc
}

ins_gzip() {
    at_desc "The granddaddy of shrinking things"
    at_gnu 1.13 && oa
}
ins_unzip() {
    at_desc "Freeing files from their zipped prisons"
    at https://downloads.sourceforge.net/infozip/unzip60.tar.gz 60 tar.gz unzip60 &&
    o && bd && make -f unix/Makefile generic CC="gcc -std=gnu89" && make prefix=/usr -f unix/Makefile install
}

# File systems & boot management

ins_syslinux() {
    at_desc "Telling your BIOS how to actually start the OS"
    at https://www.kernel.org/pub/linux/utils/boot/syslinux/Testing/6.04/syslinux-6.04-pre1.tar.gz 6.04-pre1 tar.gz &&
    o && bd && make bios install
}

ins_grub() {
    at_desc "The bouncer at the club of operating systems"
    at_gnu 2.12 && o && bd &&
    echo depends bli part_gpt > grub-core/extra_deps.lst &&
    ca --prefix=/usr --sysconfdir=/etc \
        --disable-efiemu \
        --with-platform=efi \
        --target=x86_64 \
        --disable-werror
}

ins_efivar() {
    at_desc "Poking your motherboard in its NVRAM"
    at https://github.com/rhboot/efivar/archive/39/efivar-39.tar.gz &&
    o && bd && mo ENABLE_DOCS=0 && mi ENABLE_DOCS=0 LIBDIR=/usr/lib
}

ins_efibootmgr() {
    at_desc "Reordering boot priorities so Windows doesn't win"
    at https://github.com/rhboot/efibootmgr/archive/18/efibootmgr-18.tar.gz &&
    o && bd && mo EFIDIR=LFS EFI_LOADER=grubx64.efi && mi EFIDIR=LFS
}

ins_zfs() {
    at_desc "The filesystem that eats RAM for breakfast"
    at https://github.com/openzfs/zfs/releases/download/zfs-2.4.1/zfs-2.4.1.tar.gz &&
    o && bd && cf --prefix=/usr --with-gnu-ld --disable-pyzfs \
        --enable-linux-builtin \
        --with-linux=$ldir/develop/linux-6.19.6 \
        --with-linux-obj=$bdir/linux-club-server-6.19.6 \
        --disable-linux-config-check --disable-systemd --disable-code-coverage --disable-sysvinit --disable-pam &&
    mo
}

ins_e2fsprogs() {
    at_desc "Keeping your ext4 filesystem from spontaneously combusting"
    at https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.47.4/e2fsprogs-1.47.4.tar.gz &&
    $r --sysconfdir=/etc \
        --enable-elf-shlibs \
        --disable-libblkid \
        --disable-libuuid \
        --disable-uuidd \
        --disable-fsck
}

ins_fuse() {
    at_desc "Mounting weird stuff as a legitimate filesystem"
    at https://github.com/libfuse/libfuse/releases/download/fuse-3.18.2/fuse-3.18.2.tar.gz &&
    $mur
}

# Devices

ins_kmod() {
    at_desc "Jamming code into the kernel while it's running"
    at https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-32.tar.xz &&
    oa --prefix=/usr --sysconfdir=/etc --with-zlib --with-xz --with-rootlibdir=/usr/lib &&
    make distclean &&
    cf32 --prefix=/usr --sysconfdir=/etc --with-zlib --with-xz --with-rootlibdir=/usr/lib32 --host=i686-pc-linux-gnu &&
    mo && mi32
}

ins_eudev() {
    at_desc "Managing devices without angering the systemd overlords"
    at https://github.com/eudev-project/eudev/releases/download/v3.2.14/eudev-3.2.14.tar.gz &&
    $r
}

ins_pciutils() {
    at_desc "Figuring out what graphics card you actually bought"
    at "https://git.kernel.org/pub/scm/utils/pciutils/pciutils.git/snapshot/pciutils-3.15.0.tar.gz" &&
    o && bd && sed -r '/INSTALL/{/PCI_IDS|update-pciids /d; s/update-pciids.8//}' -i Makefile &&
    make PREFIX=/usr SHAREDIR=/usr/share/hwdata SHARED=yes &&
    make PREFIX=/usr SHAREDIR=/usr/share/hwdata SHARED=yes install install-lib &&
    chmod -v 755 /usr/lib/libpci.so
}

ins_lm_sensors() {
    at_desc "Telling you exactly how close your CPU is to melting"
    at "https://github.com/lm-sensors/lm-sensors/archive/refs/tags/V3-6-2.tar.gz" 3-6-2 tar.gz && 
    $r
}
