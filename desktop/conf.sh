# Club directory
cdir=$(realpath "${CLUB_CDIR:-../}")

# Temporal directory make it RAM
tdir="${CLUB_TDIR:-/tmp/club}"

	# Build directory 
	bdir="${CLUB_BDIR:-/tmp/club/build}"

	# Sources directory
	sdir="${CLUB_SDIR:-/tmp/club/src}"

# Library 
ldir=$cdir/library

# Target arquitechture 
otar=x86_64-club-linux-gnu
otar32=i686-club-linux-gnu

# Output directory
odir="${CLUB_ODIR:-/}"

export lc_all=posix jobs=6 

cf_prefix="--prefix=/usr"


