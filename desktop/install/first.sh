# Librerias

. $cdir/util/combo.sh


ins_files(){
	
	mkdir -pv /{boot,home,mnt,opt,srv}
	mkdir -pv /etc/{opt,sysconfig}
	mkdir -pv /lib/firmware
	mkdir -pv /media/{floppy,cdrom}
	mkdir -pv /usr/{,local/}{include,src}
	mkdir -pv /usr/lib/locale
	mkdir -pv /usr/local/{bin,lib,sbin}
	mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
	mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -pv /usr/{,local/}share/man/man{1..8}
	mkdir -pv /var/{cache,local,log,mail,opt,spool}
	mkdir -pv /var/lib/{color,misc,locate}
	
	ln -sfv /run /var/run
	ln -sfv /run/lock /var/lock

	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp
	
	ln -sv /proc/self/mounts /etc/mtab
	
	cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF

	cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

	touch /var/log/{btmp,lastlog,faillog,wtmp}
	chgrp -v utmp /var/log/lastlog
	chmod -v 664  /var/log/lastlog
	chmod -v 600  /var/log/btmp
	
	return 0
	
}

ins_gettext(){
	ato gnu 0.22 && cf --disable-shared && mo &&\
	cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
	
	return $?
}

ins_perl(){
	at https://www.cpan.org/src/5.0/perl-5.40.0.tar.gz &&\
	pp=/usr/lib/perl5/5.40
	o && ./Configure -des \
             -Dprefix=/usr \
             -Dvendorprefix=/usr \
             -Duseshrplib \
             -Dprivlib=$pp/core_perl     \
             -Darchlib=$pp/core_perl     \
             -Dsitelib=$pp/site_perl     \
             -Dsitearch=$pp/site_perl    \
             -Dvendorlib=$pp/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/vendor_perl  &&\
    cd $sdir/$src &&\
	sed -i -e "s/d_perl_lc_all_category_positions_init=.*/d_perl_lc_all_category_positions_init='define'/g" \
	-e "s/d_perl_lc_all_separator=.*/d_perl_lc_all_separator='define'/g" \
	-e "s/d_perl_lc_all_uses_name_value_pairs=.*/d_perl_lc_all_uses_name_value_pairs='define'/g" config.sh &&\
	cd $sdir/$src && mo && mi
	
	return $?
}
ins_python(){
	src="Python"
	at https://www.python.org/ftp/python/3.13.7/Python-3.13.7.tar.xz &&\
	$r --enable-shared --without-ensurepip
}
ins_texinfo(){
	at gnu 7.2 && $r 
	return $?
}

ins_bison(){
	at gnu 3.8.2 && $r
	return $?
}


ins_util_linux(){
	at https://cdn.kernel.org/pub/linux/utils/util-linux/v2.40/util-linux-2.40.2.tar.gz &&\
	mkdir -pv /var/lib/hwclock
	conf="--libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python"
	$r $conf ADJTIME_PATH=/var/lib/hwclock/adjtime &&\
    make clean && cf32 $conf && mo32 && mia="DESTDIR=$PWD/DESTDIR" mi && cp -Rv DESTDIR/usr/lib/* /usr/lib32
            
            
            
	return $?
}
ins_util_linux32(){
	at https://cdn.kernel.org/pub/linux/utils/util-linux/v2.40/util-linux-2.40.2.tar.gz &&\
	src=util-linux
	CC="gcc -m32" \
	o && bd &&\
	mia="DESTDIR=$PWD/DESTDIR"
	ca --host=$otar32 \
            --libdir=/usr/lib32      \
            --runstatedir=/run       \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime && mo &&\
            mi &&\           
            cp -Rv DESTDIR/usr/lib/* /usr/lib32
	
	return $?
}

ins_finish(){
	rm -rf /usr/share/{info,man,doc}/*
	find /usr/{lib,libexec} -name \*.la -delete
	find /usr/lib32 -name \*.la -delete
	rm -rf /tools
}
