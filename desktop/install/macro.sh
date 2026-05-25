# at : selects a project from url
at_action="${at_action:-make}"
at_name=""
at_url=""
at_ver=""
at_ext=""
at_dir=""
at_archive=""
at_title=""
at_detail=""
at_task="Waiting"
at_discover=1

at(){ 
	
	at_action="${at_action:-make}"
	at_name="$project"
	at_url=""
	at_ver=""
	at_ext=""
	at_dir=""
	at_archive=""
	at_title=""
	at_detail=""
	at_task="Waiting"

	if [[ "$project" == "meta" ]]; then
		if [[ "$at_action" == "make" ]]; then
			return 0	
		fi
		return 1
	fi

    local n="$project" u="$1" v="${2:-}" e="${3:-}" d="${4:-}" bn  
    bn=$(basename "$u")
    
    # try url parse
    if [[ -z "$n" || "$n" == "$project" || -z "$v" ]]; then
        if [[ "$bn" =~ ^(.+)-(v?[0-9][^-]*)\.(tar\.(gz|xz|bz2|lz)|tgz|zip)$ ]]; then
            [[ -z "$n" || "$n" == "$item" ]] && n="${BASH_REMATCH[1]}"
            [[ -z "$v" ]] && v="${BASH_REMATCH[2]}"
            [[ -z "$e" ]] && e="${BASH_REMATCH[3]}"
        fi
    fi

    if [[ -z "$e" ]]; then
        case "$u" in
            *.tar.xz) e="tar.xz" ;;
            *.tar.gz|*.tgz) e="tar.gz" ;;  
            *.tar.bz2) e="tar.bz2" ;;
            *.tar.lz) e="tar.lz" ;;
            *.zip) e="zip" ;;
            *) e="tar.xz" ;;
        esac
    fi
    
    [[ "$u" != http* ]] && u="${u}${n}-${v}.${e}"
    [[ -z "$d" ]] && d="${n}-${v}"
    
    case "$project" in
        Python|python) d="Python-${v}" ;;
    esac
    
    at_url="$u"
    at_ver="$v"
    at_name="$n"
    at_dir="$d"
    at_archive="$n"
    at_ext="$e"
    say "$n" "🪪" "ver=$v ext=$e dir=$d"
    
    [[ "$at_action" == "obtain" ]] && { o; exit; }

    [[ "$at_action" == "desc" ]] && return 1
    
    return 0
}

at_r() {
	at_action="make"
	local u=$1
	shift
	cfs=("$@")
	say "Regular" "🤓" "at $u $v && $r $cfs"
	at $u && $r $cfs
}

ato(){
	at $@ && o
	return $?
}
at_desc() {
    local key="$project"
    local line title desc

    # si no se encuentra
    at_title="$project"
    at_detail="$1"
     
    return 1
}
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

at_gnu_mirror="https://ftp.gnu.org/gnu/"
at_gnu() {
	#name version extract-format destination-folder url
    local n v e d u
    
    v="$1"
    
    u="$at_gnu_mirror/$n/$n-$v.$e"
    
    at_url="$u"
    at_ver="$v"
    at_name="$n"
    at_dir="${d:-$n-$v}"
    at_archive="$n"
    at_ext="$e"
    
    say "$n selected" "🪪" "name=$n ver=$v ext=$e"
}

at_gnu() {
	#name version extract-format destination-folder url
    local n v e d u
    
    if [[ -z "${2:-}" ]]; then
        n="$project"
        v="$1"
        e="${2:-tar.gz}"
        d="${3:-}"
    else
        n="$1"
        v="$2"
        e="${3:-tar.gz}"
        d="${4:-}"
    fi
    
    at "https://mirror.cyberbits.eu/gnu/$n/$n-$v.$e"
    return $?
}





o(){ # Obtains sources
   
   [ ! -d "$sdir" ] && mkdir -pv $sdir;
   
    at_desc
    
    local n="$at_name"
	local sfile="$at_name-$at_ver.$at_ext"
	local sfold="$at_name-$at_ver"

	if [ -z "$at_archive" ]; then
		local sefold="$at_archive"
	else
		local sefold="$sfold"
	fi

	case "$at_ext" in
	 tgz)  tfl="-xzf" ;; 
	  tar.gz)  tfl="-xzf" ;;
	  tar.xz)  tfl="-xJf" ;;
	  tar.lz)  tfl="--lzip -xf" ;;
	  tar.bz2) tfl="-xjf" ;;
	  git)     tfl="" ;;
	  *)       show_e "unknown extension: $at_ext" ;;
	esac

	say "Obtain... " "🚚" "$at_url"

	if [ "$at_ext" = "git" ]; then
	  git_clone_safe "$ldir/$n" "$url"
	  [ ! -d "$sdir/$n" ] && cp -a "$ldir/$n" "$sdir/$n"
	else
	  # Carpeta de fuentes nueva
	  rm -rf "$sdir/$n"
	  
	  # Ver si esta en liberia, en desarrollo o tarball, sino bajamos
	  if [ -d "$ldir/develop/$n" ]; then
		say "Fuentes en desarrollo!" "🛠️"
		cp -a "$ldir/develop/$n" "$sdir/$n"
	  else
	  
		[ ! -f "$ldir/tarball/$sfile" ] && wget --no-check-certificate -O "$ldir/tarball/$sfile" "$at_url"
		say "Uncompressing ..." "📦" "$ldir/tarball/$sfile en $sdir"
		cd "$sdir" && tar $tfl "$ldir/tarball/$sfile"
		[ ! -z "$at_dir" ] && sefold="$at_dir"
		
	  fi
	  say "Obtained" "📦" "$sdir/$sefold -> $sdir/$n"
	  [ "$sefold" != "$n" ] && mv "$sdir/$sefold" "$sdir/$n"
	fi

	# Preparar build
	cd "$sdir/$n" || show_e "Expecting sources at $sdir/$n"
	#rm -rf "$bdir/$n/*"


	local inf=$(du -sh "$sdir/$n" | cut -f1)

	say "Sources $n versión $at_ver listas ( $inf ) " "⛲" "$sdir/$n"
	
	
	
	if [[ "$arg0" == "help" ]]; then
		 say "Cheking instructions"
		./configure --help | more ;
		exit;
	fi



}





# helpers
now_epoch() {
  printf '%(%s)T' -1
}

id_size() {
  [ -d "$1" ] && du -sh "$1" 2>/dev/null | cut -f1
}

# delete item build dir
di() {
  local w="${1:-$project}"
  local cleaned=""
  
  if [[ -z "$w" ]]; then
      say "Error: nombre de proyecto vacío para limpiar" "⚠️"
      return 1
  fi

  say "Cleaning build $w ..." "🚽"

  if [ -d "$sdir/$w" ]; then
      rm -rf "$sdir/$w"
      cleaned=1
  fi

  if [ -d "$bdir/$w" ]; then
      rm -rf "$bdir/$w"
      cleaned=1
  fi

  if [ -d "$bdir/layers/$w" ]; then
      rm -rf "$bdir/layers/$w"
      cleaned=1
  fi

  if [ -z "$cleaned" ]; then
      say "All clean $w" "✨"
  fi
}

# change to build dir 
bd() {
  if [ -d "$bdir/$project" ]; then
   [ ! -d "$bdir/$project" ] && mkdir -pv $sdir;
    cd "$bdir/$project" || return 1
  else
   [ ! -d "$sdir/$project" ] && mkdir -pv $bdir/$project;
    cd "$sdir/$project" || return 1
  fi
 
  say "to: $(pwd)"
}

# use separated build dir
wbd_on=""
wbd() {
  [ -d "$bdir/$project" ] && say "clean build dir" && rm -rf "$bdir/$project"
  mkdir -pv "$bdir/$project"
}

# configure/make/install flows
ca() { cf "$@" && mo && mi; }
ca() { cf "$@" && mo && mi; }
oc() { o && bd && cf "$@"; }
oa() { o && bd && cf "$@" && mo && mi; }

# configure
cf_all="--prefix=/usr --build=$otar"
cf_mes_all="--prefix=/usr"
cf_last=""
cf() {

	local res
	
	if [[ -f "$sdir/$project/configure.ac" ]]; then
		bd && autoreconf
		res=$?
		if [[ "$res" != "0" ]]; then
			return 1
		fi
	fi
	
	if [[ -f "$sdir/$project/autogen.sh" ]]; then
		bd && ./autogen.sh
		res=$?
		if [[ "$res" != "0" ]]; then
			return 1
		fi
	fi

	if [[ -f "$sdir/$project/configure" ]]; then
		 cf_last="$*"
		 cf_mode="configure"
		 	say "Configuring..." "🪛" "$cf_all $@"
		
		  bd && $sdir/$project/configure $cf_all $@
		  return $?
	fi

	if [[ -f "$sdir/$project/meson.build" ]]; then
		say "Configure found"
		cf_mode="meson"
		wbd && bd && meson setup $cf_mes_all $@ $sdir/$project
		return $?
	fi
	
	return 1
}


cf_mode="configure"

mo() {
	at_task="build"
	say "Building..." "⚒️" "make -j${jobs:-$(nproc)} $@" 
	
	case "$cf_mode" in
		configure) 
			make -j"${jobs:-$(nproc)}" "$@" 
			return $?
		;;
		meson) 
			ninja  
		return $?
		
	esac
}

# make install
mi() {
  at_task="install"
  say "Installing..." "📦" "make ${1:-} $mia install"
  
  case "$cf_mode" in
    configure) 
		make ${1:-} $mia install
		return $?
	;;
    meson) 
		ninja install  
		return $?
    ;;
	esac

  return 1
}

mess32() {
    o && wbd && bd && \
   export LIBDIR32="/usr/lib32"
	PKG_CONFIG_LIBDIR="$LIBDIR32/pkgconfig" \
	PKG_CONFIG_PATH="$LIBDIR32/pkgconfig" \
	CC="gcc -m32" \
	CXX="g++ -m32" \
	CFLAGS="-m32" \
	CXXFLAGS="-m32" \
	LDFLAGS="-L$LIBDIR32 -Wl,-rpath-link,$LIBDIR32" &&\
    cf_mes  "--libdir=lib32 $@" 
}


nin32() {
    DESTDIR="$PWD/DESTDIR" ninja install && \
    cp -rv DESTDIR/usr/lib32/* /usr/lib32/
}

mes32() {
    mess32 "$@" && nin32
}


pipb() {
  o && pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir . && \
  pip3 install --no-index --find-links=dist --no-cache-dir --no-user "$@" && di
}

cmn() {
  o && wbd && bd && cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release "$@" -G Ninja "$sdir/$project" && nin && di
      return $?
}
cmn2() {
  o && wbd && bd && cmake "$@" -G Ninja "$sdir/$project" && nin && di
  return $?
}
cmn32() {
  o && wbd && bd && \
  cmake "$@" \
    -D CMAKE_C_FLAGS="-m32" \
    -D CMAKE_CXX_FLAGS="-m32" \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_INSTALL_LIBDIR=lib32 \
    -G Ninja "$sdir/$project" && \
  nin && di
  return $?
}

a32(){
	make clean && cf32 && mo32
	return $?
}

cf32(){
	CC="gcc -m32" CXX="g++ -m32" cf --libdir=/usr/lib32  $@  
	return $?
}

mo32(){
	CC="gcc -m32" CXX="g++ -m32" mo $@
	return $?
}

r32(){
	cf32 $@ && mo && mi32
	return $?
}

ro32(){
	 cf32 && mo 
}

mi32(){
	mia="$@ DESTDIR=$PWD/DESTDIR" mi &&\
	cp -rv DESTDIR/usr/lib32/* /usr/lib32
}
mi32n(){
	mia="$@ DESTDIR=$PWD/DESTDIR" mi &&\
	cp -rv DESTDIR/usr/lib/* /usr/lib32
}


