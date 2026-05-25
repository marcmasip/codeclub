#!/bin/bash

. conf.sh
. $ldir/script/show.sh

chapter="$1"
project="$2"

chfile="install/${chapter}.sh"
[ ! -f "$chfile" ] &&  echo "No '$chfile'" && exit

installs=$(grep -E '^\s*ins_[a-zA-Z0-9_]+\s*\(' "$chfile" | sed -E 's/^\s*ins_([a-zA-Z0-9_]+).*/\1/')
[ -z "$installs" ] && echo "⚠️ Install functions 'ins_...()'." && exit 0

echo "📦 Loading chapter: $chapter..."
at_action="desc"
at_discover=0
. install/macro.sh
. "$chfile"

if [[ "$project" == "all" ]]; then
	for f in $installs; do
		func="ins_$f"
		project="$f"
		$func
	done
else
	func="ins_$project"
	$func
fi


