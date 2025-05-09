
. $CDIR/util/show.sh

set +h
umask 022

PWD=$(pwd)
[ -z "$CDIR" ] && CDIR=$(realpath $PWD/..) 
SAY "CLUB en $CDIR"

# Las guias son arquitecturas 
[ -z "$GUIDE" ] && E "NOGUIDE pff" && exit 1

# El capitulo grupos de componentes
CHAPTER="$1"

# Los items son los componentes/proyectos
ITEM="$2" 
SRC="$ITEM" 

# Donde generalmente se emite el resultado
[ -z "$ODIR" ] && E "No ODIR=$ODIR pff" && exit 1
ODIR=$(realpath $ODIR)

SAY "SALIDA en $ODIR"

# Aqui van los tarballs, carpetas de fuentes, carpetas de fuentes en desarrollo
[ -z "$LDIR" ] && LDIR=$CDIR/library
[ ! -d "$LDIR" ] && E "No library dir: $LDIR , pff !" && exit 1

# Estos deben ser temporales en ram para no rayar el disco
[ -z "$TDIR" ] && TDIR=$CDIR/tmp
[ -z "$BDIR" ] && BDIR=$TDIR/build
[ -z "$SDIR" ] && SDIR=$TDIR/src
[ -z "$GDIR" ] && GDIR=$TDIR/log
[ -z "$RDIR" ] && RDIR=$TDIR/log

[ ! -d "$BDIR" ] && mkdir -p "$BDIR"
[ ! -d "$SDIR" ] && mkdir -p "$SDIR"
[ ! -d "$GDIR" ] && mkdir -p "$GDIR"
[ ! -d "$VDIR" ] && mkdir -p "$VDIR"

#
# Configure thingys
#

# Delete item build dir
DI(){
	local w="$SRC"
	[ ! -z "$1" ] && w="$1"
	local cleaned=""
	[ -d "$BDIR/$w" ] && rm -rf $BDIR/$w && cleaned=1
	[ -d "$SDIR/$w" ] && rm -rf $SDIR/$w && cleaned=1
	[ -z "$cleaned" ] && SAY "Limpiando $w " "🚽"
	return 0
}

# Change to Build Dir 
BD(){
	
	if [ -d "$BDIR/$SRC" ]; then
		cd "$BDIR/$SRC"
	else
		cd "$SDIR/$SRC"
	fi
	SAY "To: $(pwd)"
	return $?
}

# Use separated build dir
WBD(){
	[ -d "$BDIR/$SRC" ] && SAY "Clean build dir" && rm -rf $BDIR/$SRC
	SAY "Directorio para compilar"
	mkdir -pv "$BDIR/$SRC" 
}

# Configure, Make Objects, Make Install
CA(){
	CF $@ && MO && MI 
	return $?
}

# Obtain and configure
OC(){
	O && BD && CF $@
	return $?
}

# Obtain and all
OA(){
	O && BD && CF $@ && M
}

# Configure
CF(){
	SW_TASK "Configurando"
	SAY "CONFIGURANDO CON: $@"
	BD && $SDIR/$SRC/configure $@ && CNT_CHECK
	return $?
}

# Make Objects
MO(){
	SW_MOTD "$(MOTD_COMPILE)"
	local MK="make $@"
	SW_TASK "Compilando objetos"
	$MK -j$JOBS && CNT_CHECK
	return $?
}

# Make Install MIA for arguments 
MIA=""
MI(){
	SW_TASK "Instalando"
	SW_MOTD "$(MOTD_INSTALL)"
	SAY "make $MIA install"
	make $1 $MIA install && CNT_CHECK
	return $?
}


M(){
	MO && MI $@
	return $?
}


MT(){
	MO && SW_TASK "Instalando" && make DESTDIR=$ODIR install && CNT_CHECK
	return $?
}
NIN(){
	ninja && ninja install
}
MESS(){
	O && WBD && BD && meson setup $@ $SDIR/$SRC 
}
MES(){ 
	MESS $@ && NIN
}

PIPB(){
	O && pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir . &&\
	pip3 install --no-index --find-links=dist --no-cache-dir --no-user $@ && DI
	
}
CMN(){
	O && WBD && BD && cmake $@ -G Ninja $SDIR/$SRC && NIN && DI 
}
FDEF(){
	cp -R $CDIR/util/defaults/$1 $ODIR/$1
}
ID(){
	[ -d "$1" ] && echo $(du -hs $1)
}


MOTD_OK() {
    if [ -f $CDIR/util/MOTD_OK.txt ]; then
        shuf -n 1 $CDIR/util/MOTD_OK.txt
    else
        echo "OK"
    fi
}
MOTD_ERR() {
    if [ -f $CDIR/util/MOTD_ERR.txt ]; then
        shuf -n 1 $CDIR/util/MOTD_ERR.txt
    else
        echo "No tengo frases de error"
    fi
}
MOTD_OBTAIN() {
    if [ -f $CDIR/util/MOTD_OBTAIN.txt ]; then
        shuf -n 1  $CDIR/util/MOTD_OBTAIN.txt
    else
        echo "Obtain"
    fi
}
MOTD_COMPILE() {
    if [ -f  $CDIR/util/MOTD_COMPILE.txt ]; then
        shuf -n 1  $CDIR/util/MOTD_COMPILE.txt
    else
        echo "Compile"
    fi
}
MOTD_INSTALL() {
    if [ -f  $CDIR/util/MOTD_INSTALL.txt ]; then
        shuf -n 1  $CDIR/util/MOTD_INSTALL.txt
    else
        echo "Install"
    fi
}


#
# Library Manager
#
declare -A PKG_MAP  
declare -A PKG_MAP_DESC
load_pkg_data() {
  while read -r id ver ext url xfd; do
    [ ! -z "$id" ] && PKG_MAP["$id"]="$ver|$ext|$url|$xfd"
  done < "$CDIR/util/obtain.txt"
  
 while IFS='|' read -r id title desc; do
 id="${id#"${id%%[![:space:]]*}"}"
  id="${id%"${id##*[![:space:]]}"}"

  title="${title#"${title%%[![:space:]]*}"}"
  title="${title%"${title##*[![:space:]]}"}"

  desc="${desc#"${desc%%[![:space:]]*}"}"
  desc="${desc%"${desc##*[![:space:]]}"}"

  [ -n "$id" ] && PKG_MAP_DESC["$id"]="$title|$desc"
done < "$CDIR/util/obtain_desc.txt"
}

load_pkg_data


PKG_ID=""
PKG_VER=""
PKG_EXT=""
PKG_URL=""
PKG_XFD=""
INF_PKG() {
  local id="$1"
  local data="${PKG_MAP[$id]}"
  if [ -z "$data" ]; then
    E "No package $id."
    exit 1
  fi

  IFS='|' read -r PKG_VER PKG_EXT PKG_URL PKG_XFD <<< "$data"
  PKG_ID="$id"
  PKG_TAR="$LDIR/$PKG_ID-$PKG_VER.$PKG_EXT"
  INF_PKG_DESC "$PKG_ID"
  SAY "Identificado: $PKG_ID ( $PKG_VER )" "🪪" "Origen $PKG_URL"
}

PKG_TITLE=""
PKG_DESC=""
INF_PKG_DESC(){
  local id="$1"
  local data="${PKG_MAP_DESC[$id]}"
  if [ -z "$data" ]; then
	SAY "No package desc $id."
	PKG_TITLE="$id"
	PKG_DESC="???"
	return
  fi

  IFS='|' read -r PKG_TITLE PKG_DESC <<< "$data"
}


#
# Obtain the goat
#

O(){

	SW_MOTD "$(MOTD_OBTAIN)"
	
	if [ -z "$1" ]; then
		pkgs="$SRC"
	else	
		pkgs="$@"
	fi
	for pkg in $pkgs; do		
	
		
		INF_PKG $pkg
		
		[ -z "$PKG_EXT"  ] && PKG_EXT="tar.gz"
		tfl="-xzf"
		[ "$PKG_EXT" == "tar.xz"  ] && tfl="-xJf"
		[ "$PKG_EXT" == "tar.lz"  ] && tfl="--lzip -xf"
		[ "$PKG_EXT" == "tar.bz2"  ] && tfl="-xjf"
		
		
		if [ "$PKG_EXT" == "git" ]; then
		
			cd $LDIR
			if [ ! -d "$pkg" ]; then
				SAY "Clonando git"
				git clone $PKG_URL $pkg && E "No se bajo" && exit
			fi
		
			cd $SDIR
			if [ ! -d "$pkg" ]; then
				SAY "Copiando fuentes"
				rm -rf $pkg #always clean ?
				cp -a $LDIR/$pkg ./$pkg
			fi
			
			
		
		else
			
			sfile="$pkg-$PKG_VER.$PKG_EXT"
			sfold="$pkg-$PKG_VER"
			[ -z "$PKG_URL"  ] && PKG_URL="https://ftp.gnu.org/gnu/$pkg/$sfile"
			[ -z "$PKG_XFD"  ] && PKG_XFD="$sfold"
			
			
			
			cd $SDIR
			rm -rf $pkg #always clean ?
			if [ -d "$LDIR/develop/$pkg" ]; then
				SAY "Fuentes en desarrollo!" "🛠️"
				cp -a $LDIR/develop/$pkg ./$PKG_XFD
			else
			
				#try to download
				cd $LDIR
				if [ ! -f "$sfile" ]; then
					/usr/bin/wget --no-check-certificate -O $sfile $PKG_URL
					[ "$?" != 0 ] && E "No se bajo" && exit
				fi
				
				cd $SDIR
				SAY "Descomprimiendo ..."
				tar $tfl $LDIR/$sfile 
			fi
			
			if [ "$PKG_XFD" != "$pkg" ]; then
				mv $PKG_XFD $pkg 
			fi
		fi
		
		cd $pkg 
		ready=$?
		
		
		if [ "$ready" == "0" ];then
			[ -d $BDIR/$pkg ] && rm -rf $BDIR/$pkg
			CNT_CHECK
			inf=$(du -sh "$SDIR/$pkg"| awk '{print $1}') 

			echo "$PKG_TITLE" >  $BDIR/task.title.info
			echo "$PKG_DESC" >  $BDIR/task.desc.info
			
			SAY "Fuentes $pkg versión $ver listas ( $inf ) " "⛲"
			return 0
		else
			E " obteniendo $pkg"
			
			return 1
		fi
		        
    done

}




#
# Request Item:   sirve para listas de items
# 

R_ARRAY=()
R_ARRAYP=()
R(){
	 R_ARRAY+=("$1")
	 R_ARRAYP+=(" 📦$1")
}
DO_R_I() {
	f="$GUIDE-$CHAPTER-$1.res"
	rf="$VDIR/$f"
	if [ ! -f "$rf" ]; then
        SAY  "${BOLD}$f${RESET} no ha sido encontrado, augura la necesidad de acciones futuras." "🧨" "$(MOTD_ERR)"

    elif [ "$(head -n 1 "$rf")" != "0" ]; then
        SAY  "${BOLD}$f${RESET} ha fallado en su misión!" "🔥" "$(MOTD_ERR)"
		
    else
        SAY  "${BOLD}$1${RESET}" "✅" "$(MOTD_OK)"
        return 0
    fi
	
    export ITEM="$1"
    SRC="$ITEM"
    
   
    # [ -z "$CONFIRMED" ] && CONFIRMED="1" && CONFIRM
	GUIDE_ITEM
	res=$?
	echo "$res" > $rf
	
	[ "$res" != "0" ] && exit;
	
	
    return $res
}


DO_R() {
	
	SAY "Se requieren: $(IFS=, ; echo "${R_ARRAYP[*]}")"

	export INFO_ITEM_T="${#R_ARRAY[@]}"
    for item in "${R_ARRAY[@]}"; do
        DO_R_I $item
       
		export INFO_ITEM_C=$((INFO_ITEM_C + 1))
    done
}

GUIDE_ITEM(){
	[ ! -z "$1" ] && ITEM="$1"
	
	SHOW_RF=$VDIR/$GUIDE-$CHAPTER-$ITEM.res
	SHOW_LOG=$GDIR/$GUIDE-$CHAPTER-$ITEM.log
	SHOW GUIDE_ITEM_LOAD

	echo "
	
	
	
	
	
	
	

"
	[ "$SHOW_RES" != "0" ] && E "Resultado $SHOW_RES haciendo: $CHAPTER-$ITEM "
	
	[ "$SHOW_RES" == "0" ] &&  DI

	
	SAY "$ITEM terminado en $SHOW_RES" "🚬" "$(MOTD_OK)"
	echo " "
	return $SHOW_RES
	
}

GUIDE_ITEM_LOAD(){
	[ ! -z "$1" ] && ITEM="$1"
	p="$CDIR/${GUIDE}/items-$CHAPTER.sh"
	[ ! -f "$p" ] && E "No chapter $p" && exit
	SAY "Cargando capítulo $CHAPTER ..." "📜"
	CNT_CHECK
	SRC=$ITEM
	if [[ "$SRC" == *-32 ]]; then
		SRC="${SRC%*-32}"
	fi
    SAY "SRC=$SRC"
	. $p
	return $?
}




#
# 
# 

SAY "code $(PCCOLOR 'c')$(PCCOLOR 'l')$(PCCOLOR 'u')$(PCCOLOR 'b') guides" "📐"

INFO_KPI_VAL=("1" "2" "3")
INFO_KPI_NAME=("📂" "📜" "⚒️")
INFO_KPI_NUM=${#INFO_KPI_VAL[@]}


[ -z "$SHOW_TITLE" ] && export SHOW_TITLE="$ITEM"
export SHOW_TIME=$(date +%s)

SH_TITLE="$ITEM"
SH_DESC=""
SH_TASK=""

CNT_CHECK(){
	INFO_KPI_VAL[0]="$(ID $ODIR/usr)"
	INFO_KPI_VAL[1]="$(ID $SDIR)"
	INFO_KPI_VAL[2]="$(ID $BDIR)"
}




