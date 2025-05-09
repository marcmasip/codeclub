# Base components setup

# Shortcuts


MIA=""
r="OA --prefix=/usr "

# Item plans

case "$ITEM" in

"welcome")


mkdir -pv /{boot,home,mnt,opt,srv}
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/lib/locale
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}

FDEF /etc/hosts
FDEF /etc/passwd
FDEF /etc/group

localedef -i es_ES -f UTF-8 es_ES.UTF-8

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

;;

"gettext")
	O && CF --disable-shared && MO &&\
	cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

;;


"perl") 
	
	pp=/usr/lib/perl5/5.40
	O && ./Configure -des \
             -Dprefix=/usr \
             -Dvendorprefix=/usr \
             -Duseshrplib \
             -Dprivlib=$pp/core_perl     \
             -Darchlib=$pp/core_perl     \
             -Dsitelib=$pp/site_perl     \
             -Dsitearch=$pp/site_perl    \
             -Dvendorlib=$pp/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/vendor_perl  &&\
    cd $SDIR/$SRC &&\
	sed -i -e "s/d_perl_lc_all_category_positions_init=.*/d_perl_lc_all_category_positions_init='define'/g" \
	-e "s/d_perl_lc_all_separator=.*/d_perl_lc_all_separator='define'/g" \
	-e "s/d_perl_lc_all_uses_name_value_pairs=.*/d_perl_lc_all_uses_name_value_pairs='define'/g" config.sh &&\
	cd $SDIR/$SRC && MO && MI ;;


"python") $r --enble-shared --without-ensurepip ;;

"util-linux")
	mkdir -pv /var/lib/hwclock
	$r --libdir=/usr/lib     \
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
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime 
;;

"util-linux32")
	SRC=util-linux
	CC="gcc -m32" \
	O && BD &&\
	MIA="DESTDIR=$PWD/DESTDIR"
	CA --host=$OTAR32 \
            --libdir=/usr/lib32      \
            --runstatedir=/run       \
            --docdir=/usr/share/doc/util-linux-2.41 \
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
            ADJTIME_PATH=/var/lib/hwclock/adjtime && MO &&\
            MI &&\           
            cp -Rv DESTDIR/usr/lib32/* /usr/lib32

;;

"clean")
	
	rm -rf /usr/share/{info,man,doc}/*
	find /usr/{lib,libexec} -name \*.la -delete
	rm -rf /tools
;;







*) $r ;;


esac
