# Codeclub: Preparation

bdir="${CLUB_BDIR:-/tmp/club/build}"
tdir="${CLUB_TDIR:-/tmp/club}"
cdir=$(realpath "${CLUB_CDIR:-../}")
ldir=$cdir/library

. $ldir/script/show.sh

chapter=$1
item=$2
arg0=$3

. 
