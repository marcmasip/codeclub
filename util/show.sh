#
# PRINT BASIC FUNCTIONS
#
SAY(){
	local ico="$2"
	[ -z "$ico" ] && ico="📰"	
	echo -e "\
	 ╭┈┈┈┈╮ 
	 │ $ico │ $BOLD$1$CRS  
	 ╰┈┈┈┈╯  \e[3m\e[37m$3$CRS"
}
E(){
	SAY "$1" "🔥"
	exit 1
}

PICON(){
	echo -e "\
╭┈┈┈┈╮\
\e[6D\e[1B│ $1 │\
\e[6D\e[1B╰┈┈┈┈╯ \e[0m \e[1A$2 \e[1A"
}
PCCOLOR() {
    local color_code=$((30 + RANDOM % 8))
    local char="$1"
    echo -ne "\033[${color_code}m${char}\033[0m"
}

CONFIRM(){
	ORANGE='\033[38;5;208m'
	BOLD='\033[1m'
	CRS='\033[0m'
	SAY  "Confirma	${BOLD}$CHAPTER${CRS}/${BOLD}$ITEM${CRS}"  "❔" "Destino:	${BOLD}$ODIR${CRS}"
	read uok
	[ "$uok" != "y" ] && echo "Cancelled " && exit 1
	return 0
}




#
# SHOW PROGRESS
#

SHOW_TASK="Empezando ..."
DEC="$(PCCOLOR '┈')"
SW_MOTD(){
	echo "     "
	echo $1 > $BDIR/motd.info
}

SW_TASK(){
	echo "     "
	echo $1 > $BDIR/task.info
}
SHOW_RF=""
SHOW_LOG=""
SHOW(){
	SHOW_RES=-1
	[ -z "$SHOW_RF" ] && SHOW_RF=$(mktemp)
	TIMEINI=$(date +%s)
	(		
		$@
		echo "$?" > "$SHOW_RF"
		 
	 ) 2>&1 | while IFS= read -r line
	do
	  [ ! -z "$SHOW_LOG" ] && echo "$line" >> "$SHOW_LOG"
	  SHOW_LINE "$line"
	done
	if [ -e $SHOW_RF ]; then
		SHOW_RES=$(cat $SHOW_RF)
		rm $SHOW_RF
		SHOW_RF="":
	else
		SHOW_RES=1
	fi
	return $SHOW_RES
}

INFO_ITEM_T="1"
INFO_ITEM_C="1"
kpistr=""
SHOW_LINE() {
  line="$1"	
  local current_time=$(date +%s)
  local elapsed=$((current_time - TIMEINI))
  local mins=$((elapsed / 60))
  local secs=$((elapsed % 60))
  time=$(printf "%02d:%02d" "$mins" "$secs" )
  
  elapsed=$((current_time - SHOW_TIME))
  mins=$((elapsed / 60))
  secs=$((elapsed % 60))
  timeg=$(printf "%02d:%02d" "$mins" "$secs" )
  
  doing="other"
  
  
  case "$line" in
	"     ")
	INFO_MOTD=$(cat $BDIR/motd.info)
	SHOW_TASK=$(cat $BDIR/task.info)
	PKG_TITLE=$(cat $BDIR/task.title.info)
	PKG_DESC=$(cat $BDIR/task.desc.info)
	
	local input="$PKG_DESC"
	local max_len=${2:-50}  # Límite opcional

	DESC_1="${input:0:$max_len}"
	DESC_2="${input:$max_len}"
	
	

	
	CNT_CHECK
	
	
	kpistr=""
	for ((i=0; i<INFO_KPI_NUM; i++)); do
		kpistr="$kpistr$(PICON ${INFO_KPI_NAME[$i]} ${INFO_KPI_VAL[$i]} )"
	done
	
	
	
	;;
  
    *check*|*CHECK*)
      doing="🔎 check"
      ;;
    *gcc*|*g++*|*ld*|*make*|*.o*|*.c*)
      doing="🔨 comp."
      CNT_BF=$((CNT_BF + 1))
      ;;
    *)
      doing="📦 other"
      ;;
  esac
	
	
  blank="\
                                                                        "
  t="$blank\r"
 # echo "$time | $CNT_BF $line ";
 
   now=$(current_time)
 
  echo -e "$t$line
$t
$t╭┈┈┈┈┈┈┈┈┈┈┈┈┈ ⚔️  Ahora \e[35G⏱️  $timeg ┈┈┈┈┈┈┈┈┈┈┈┈┈┈╮  
$t│  \e[97m$PKG_TITLE\e[0m \e[57G │  
$t│  \e[37m$DESC_1\e[0m \e[57G │  
$t│  \e[37m$DESC_2\e[0m \e[57G │  
$t│  \e[90m$SHOW_TASK\e[0m \e[57G │  
$t│  📒 \e[1m$ITEM\e[0m	\e[57G │  
$t│  └📄 ~$CNT_BF \e[90m	\e[25G \e[0m $doing \e[50G⏱️  $time│ 
$t╰┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈╯\r\e[9A\e7\
\e[H\
$t│  \e[1;58H│                                                               
$t│  🐣 \e[1mcode $(PCCOLOR 'c')$(PCCOLOR 'l')$(PCCOLOR 'u')$(PCCOLOR 'b') \
\033[0m lvl. 2  		\e[2;58H│
$t│     \e[90mARCH: \e[0m\033[1m$GUIDE \e[90mCH: \e[0m\033[1m$CHAPTER \e[0m\e[90mITEM($INFO_ITEM_C/$INFO_ITEM_T): \e[0m\033[1m$ITEM\033[0m \e[0m\e[3;58H│                                                               
$t│     \e[3m\033[37m ${ROTA_TEXT[$ROTA_INDEX]} \033[0m\e[4;58H│                                                               
$t│  \e[3m\033[37m$INFO_MOTD \e[5;58H│                                                               
$t╰┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈╯
\e[H\e[59C $kpistr \e8"

    now=$(current_time)
    elapsed=$(awk "BEGIN { print $now - $LAST_FRAME_TIME }")

    if (( $(awk "BEGIN { print ($elapsed >= $FRAME_DELAY) }") )); then
      
        ((ROTA_INDEX=(ROTA_INDEX+1)%${#ROTA_TEXT[@]}))
        LAST_FRAME_TIME=$now
    fi
    
    
    
}



current_time() {
    date +%s.%N
}

ROTA_INDEX=0
LAST_FRAME_TIME=0
FRAME_DELAY=0.2 

ROTA_TEXT=(\
"   🌲                    🚚    🏪 " \
"     🌲                 🚚     🏪 " \
"       🌲              🚚      🏪" \
"         🌲           🚚        🏪" \
"           🌲        🚚         🏪" \
"             🌲     🚚          🏪" \
"               🌲  🚚            " \
"  🌳              🚚             " \
"    🌳           🚚  🌲          " \
"      🌳        🚚     🌲        " \
"        🌳     🚚        🌲      " \
"          🌳  🚚            🌲   " \
"             🚚               🌲 " \
"  🏠        🚚  🌳               " \
"    🏠     🚚     🌳             " \
"      🏠  🚚        🌳           " \
"         🚚           🌳         " \
"        🚚  🏠          🌳       " \
"       🚚      🏠          🌳    " \
"      🚚          🏠             " \
"     🚚              🏠          " \
"    🚚                  🏠       " \
"   🚚                      🏠    " \
"  🚚                           🏠 " \
"🚚                              💾" \
"🚚🏃‍➡️                            💾" \
"🚚  🚶                          💾" \
"🚚📦🚶                         💾 " \
"🚚  🏃‍➡📦️                       💾 " \
"🚚   🚶‍➡‍‍📦️                      💾 " \
"🚚    🏃‍➡📦️                     💾 " \
"🚚     🚶‍➡‍‍📦️                    💾 " \
"🚚      🏃‍➡📦️                   💾 " \
"🚚       🚶‍➡‍‍📦️                  💾 " \
"🚚        🏃‍➡📦️                 💾 " \
"🚚         🚶‍➡‍‍📦️                💾 " \
"🚚          🏃‍➡📦️               💾 " \
"🚚           🚶‍➡‍‍📦️              💾 " \
"🚚            🏃‍➡📦️             💾 " \
"🚚            🏃‍➡  📦️           💾 " \
"🚚            🚶‍➡   ‍‍📦️          💾 " \
"🚚            🚶‍➡   ‍‍ 📦️         💾 " \
"🚚            🚶‍➡   ‍‍  📦️        💾 " \
"🚚            🚶    ‍‍  📦️       💾 " \
"🚚           🏃     ‍‍   📦️      💾 " \
"🚚          🚶      ‍‍    📦️     💾 " \
"🚚         🏃         ‍‍   📦️    💾 " \
"🚚        🚶           ‍‍   📦️   💾 " \
"🚚       🏃            ‍‍   📦️ 🫲💾 " \
"🚚      🚶             ‍‍    📦️🫲💾 " \
"🚚     🏃              ‍‍      🤛💾 " \
"🚚    🚶               ‍‍        💾 " \
"🚚   🏃                ‍‍        💾 " \
"🚚  🚶                 ‍‍        💾 " \
"🚚 🏃                  ‍‍        💾 " \
"🚚🚶                   ‍‍        💾 " \
"🚚                     ‍‍        💾 " \
"                     ‍‍          💾 " \
)



