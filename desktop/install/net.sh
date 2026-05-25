

ins_inetutils(){
    # Utilidades de red como telnet, ftp, etc.
    # Deshabilitamos los servidores y herramientas obsoletas o inseguras.
    at_gnu 2.6 &&\
    LIBS="-lncursesw" oa --prefix=/usr --disable-logger --disable-whois --disable-rcp \
       --disable-rexec --disable-rlogin --disable-rsh --disable-servers
    return $?
}

ins_dhcpcd(){
	at "https://github.com/NetworkConfiguration/dhcpcd/releases/download/v10.0.8/dhcpcd-10.0.8.tar.xz" && \
	$r      --sysconfdir=/etc            \
            --libexecdir=/usr/lib/dhcpcd \
            --dbdir=/var/lib/dhcpcd      \
            --runstatedir=/run           \
            --disable-privsep
	return $?
}
ins_ntp(){
	at "https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p18.tar.gz" && \
	o && sed -e "s;pthread_detach(NULL);pthread_detach(0);" \
    -i configure \
       sntp/configure && ca --prefix=/usr --bindir=/usr/sbin \
            --sysconfdir=/etc  \
            --enable-linuxcaps \
            --with-lineeditlibs=readline 
	return $?
}
ins_chrony(){
	at https://chrony-project.org/releases/chrony-4.8.tar.gz
	return oa
}

ins_openssl(){
    # La librería criptográfica por excelencia. Su compilación no es estándar.
    # Se configura para 64 bits y luego para 32 bits (linux-x86).
    at https://www.openssl.org/source/openssl-3.5.2.tar.gz && o && bd &&\
    ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic &&\
    mo && mi &&\
    make clean &&\
    ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib32 shared zlib-dynamic linux-x86 &&\
    mo && make DESTDIR=$PWD/DESTDIR install &&\
    cp -Rv DESTDIR/usr/lib32/* /usr/lib32 && rm -rf DESTDIR
    return $?
}
ins_openssh(){
	at "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.0p1.tar.gz" &&\
	$r --sysconfdir=/etc/ssh                    \
            --with-privsep-path=/var/lib/sshd        \
            --with-default-path=/usr/bin             \
            --with-superuser-path=/usr/sbin:/usr/bin \
            --with-pid-dir=/run 
	
	return $?
}


ins_wget(){
	at gnu 1.24.5 &&\
	$r --with-gnu-ld --sysconfdir=/etc --with-ssl=openssl
	return $?
}
ins_curl(){
	at https://curl.se/download/curl-8.16.0.tar.xz &&\
	$r --disable-static --with-openssl  --with-ca-path=/etc/ssl/certs --with-ca=/etc/ssl/certs
	
	return $?	
}



ins_nftables(){
	at https://www.netfilter.org/projects/nftables/files/nftables-1.1.6.tar.xz && $r
	return $?
}

ins_iptables(){
	at https://www.netfilter.org/projects/iptables/files/iptables-1.8.12.tar.xz &&\
	$r --enable-libipq
	return $?
}	
	
ins_bridge_utils(){
	at "https://www.kernel.org/pub/linux/utils/net/bridge-utils/bridge-utils-1.7.1.tar.xz" &&\
		o && bd && autoconf && ca --prefix=/usr
	return $?
}


