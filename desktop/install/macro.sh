#!/usr/bin/env bash

# Selects a project
at_action="make"
at_name=""
at_url=""
at_ver=""
at_ext=""
at_dir=""
at_archive=""
at_title=""
at_detail=""

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
    local key="$src"
    local line title desc

    while IFS='|' read -r name title desc; do
        
         name=$(trim "$name")
        title=$(trim "$title")
        desc=$(trim "$desc")
		
        if [[ $name == "$key" ]]; then
            at_title=$title
            at_detail=$desc
			say "$at_title" " " "$at_detail"
            return 0
        fi
    done < "$cdir/util/obtain_desc.txt"

    # si no se encuentra
    at_title="?"
    at_detail="?"
     
    return 1
}
trim() {
    local var="$*"
    # quitar espacios iniciales
    var="${var#"${var%%[![:space:]]*}"}"
    # quitar espacios finales
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

at_gnu() {
    local n v e d u
    
    if [[ -z "${2:-}" ]]; then
        n="$src"
        v="$1"
        e="${2:-tar.gz}"
        d="${3:-}"
    else
        n="$1"
        v="$2"
        e="${3:-tar.gz}"
        d="${4:-}"
    fi
    
    u="http://mirror.cyberbits.eu/gnu/$n/$n-$v.$e"
    
    at_url="$u"
    at_ver="$v"
    at_name="$n"
    at_dir="${d:-$n-$v}"
    at_archive="$n"
    at_ext="$e"
    
    say "$n seleccionado" "🪪" "name=$n ver=$v ext=$e"
}

at(){ # Selects the project from url
	
 : "${TERM:=dumb}"
    local n="$src" u="$1" v="${2:-}" e="${3:-}" d="${4:-}" bn
    
    bn=$(basename "$u")
    
    # Extraer name-ver.ext (con o sin prefijo v)
    if [[ -z "$n" || "$n" == "$src" || -z "$v" ]]; then
        # Captura versiones con o sin 'v' al inicio
        if [[ "$bn" =~ ^(.+)-(v?[0-9][^-]*)\.(tar\.(gz|xz|bz2|lz)|tgz|zip)$ ]]; then
            [[ -z "$n" || "$n" == "$src" ]] && n="${BASH_REMATCH[1]}"
            [[ -z "$v" ]] && v="${BASH_REMATCH[2]}"
            [[ -z "$e" ]] && e="${BASH_REMATCH[3]}"
        fi
    fi
    
    # Deducir extensión
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
    
    case "$n" in
        Python|python) d="Python-${v}" ;;
    esac
    
    at_url="$u"
    at_ver="$v"
    at_name="$n"
    at_dir="$d"
    at_archive="$n"
    at_ext="$e"
    
    say "$n seleccionado" "🪪" "name=$n ver=$v ext=$e dir=$d"
    
    [[ "$at_action" == "close" ]] && { o; exit; }
    
    return 0

}



o(){ # Obtains sources
   
    at_desc
    show_title_item=$item
    show_set "$at_title" "$at_detail" "$at_name $at_ver"

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
	  *)       show_e "extensión desconocida: $at_ext" ;;
	esac

	say "Obteniendo " "🚚" "$at_url"

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
		say "Descomprimiendo ..." "📦" "$ldir/tarball/$sfile en $sdir"
		cd "$sdir" && tar $tfl "$ldir/tarball/$sfile"
	  fi
	  say "Obtenido" "xx" "$sdir/$sefold -> $sdir/$n"
	  [ "$sefold" != "$n" ] && mv "$sdir/$sefold" "$sdir/$n"
	fi

	# Preparar build
	cd "$sdir/$n" || show_e "Se esperaban fuentes en $sdir/$n"
	#rm -rf "$bdir/$n/*"


	local inf=$(du -sh "$sdir/$n" | cut -f1)
	#printf '%s\n' "$n" > "$bdir/task.title.info"
	#printf '%s\n' "$prj_desc" > "$bdir/task.desc.info"

	say "Fuentes $n versión $at_ver listas ( $inf ) " "⛲" "$sdir/$n"

	if [[ "$arg0" == "help" ]]; then
		 say "Viendo instrucciones"
		./configure --help | more ;
		exit;
	fi



}



# BUILD

mkdir -pv "$bdir" "$sdir" "$gdir" "$vdir"
show_motd="Pack de construcción"

# helpers
now_epoch() {
  printf '%(%s)T' -1
}

id_size() {
  [ -d "$1" ] && du -sh "$1" 2>/dev/null | cut -f1
}

# delete item build dir
di() {
  local w="${1:-$src}"
  local cleaned=""
  [ -d "$bdir/$w" ] && rm -rf "$bdir/$w" && cleaned=1
  [ -d "$sdir/$w" ] && rm -rf "$sdir/$w" && cleaned=1
  [ -z "$cleaned" ] && say "limpiando $w " "🚽"
}

# change to build dir 
bd() {
  if [ -d "$bdir/$src" ]; then
    cd "$bdir/$src" || return 1
  else
    cd "$sdir/$src" || return 1
  fi
  say "to: $(pwd)"
}

# use separated build dir
wbd_on=""
wbd() {
  [ -d "$bdir/$src" ] && say "clean build dir" && rm -rf "$bdir/$src"
  say "directorio para compilar"
  mkdir -pv "$bdir/$src"
  wbd_on="1"
}

# configure/make/install flows
ca() { cf "$@" && mo && mi; }
oc() { o && bd && cf "$@"; }
oa() { o && bd && cf "$@" && m; }

cf_last=""
cf() {
  sw_task "configurando"
  say "config con: $*"
  cf_last="$*"
  [ "$arg0" == "show" ] && echo "$sdir/$src/configure" "$@" && exit
  bd && "$sdir/$src/configure" "$@" 
}

mo() {
  sw_motd "$(motd_compile)"
  sw_task "compilando objetos"
  make -j"${jobs:-$(nproc)}" "$@" 
}

mi() {
  sw_task "instalando"
  sw_motd "$(motd_install)"
  say "make $mia install"
  make ${1:-} $mia install
}

m() { mo && mi "$@"; }

mt() {
  mo && sw_task "instalando" && make DESTDIr="$odir" install 
}

nin() { ninja && ninja install; }
mess() { o && wbd && bd && meson setup "$@" "$sdir/$src"; }
mes() { mess "$@" && nin; }
mess32() {
    o && wbd && bd && \
    PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
    CC="gcc -m32" CXX="g++ -m32" \
    meson setup --libdir=lib32 "$@" "$sdir/$src"
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
      -D CMAKE_BUILD_TYPE=Release "$@" -G Ninja "$sdir/$src" && nin && di
      return $?
}
cmn2() {
  o && wbd && bd && cmake "$@" -G Ninja "$sdir/$src" && nin && di
  return $?
}
cmn32() {
  o && wbd && bd && \
  cmake "$@" \
    -D CMAKE_C_FLAGS="-m32" \
    -D CMAKE_CXX_FLAGS="-m32" \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_INSTALL_LIBDIR=lib32 \
    -G Ninja "$sdir/$src" && \
  nin && di
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

run_item() {
   
    local rf log
    
   

    rf="$vdir/$guide-$chapter-$item.res"
    log="$gdir/$guide-$chapter-$item.log"


    show_rf="$rf"
    show_log="$log"


	if [[ "$arg0" == "help" ]]; then
		ins_$item 
	else
		
		item_lo="${item//-/_}"
		say "Ejecutando ins_$item_lo"
		ins_$item_lo
	fi
    local res=$?

    if (( res != 0 )); then
		 echo -e "\n\n\n\n\n\n\n\n"
        say "resultado $res haciendo $chapter-$item" "🥀"
       
        exit
    else
        di
    fi

    say "$item terminado en $res" "🚬" "$(motd_ok)"
    echo -e "\n\n\n\n\n\n\n\n"

    return "$res"
}

