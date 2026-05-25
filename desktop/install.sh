#!/bin/bash
# codeclub project/package manager

. conf.sh
. $ldir/script/show.sh

chapter=$1
project=$2
mode=$3
arg=$4

cdn="https://cdn.azestudio.net/codeclub"
cdndir=/mnt/mech/live/codeclub/latest
cdnhost=root@club

ins_once() {
    local insdir=$odir/var/club/installed
    mkdir -p "$insdir"
    [ -f "$insdir/$chapter-$project.log" ] && return 1
    say "Installing $1 ..."
    ins_$project && echo "$at_ver" > "$insdir/$chapter-$project.log"
}
ins_safe() {
    local item=$project
    local upper="$bdir/layers/$item/upper"
    local work="$bdir/layers/$item/work"

    sudo rm -rf "$bdir/layers/$item"
    mkdir -p "$upper" "$work"

    say "Sandboxing '$item'..." "🥪"
    sudo unshare --mount -- bash -c '
        upper=$1 work=$2 cdir=$3 chapter=$4 project=$5
        ROOTFS=$(mktemp -d)
        cleanup() {
            umount "$ROOTFS/club" "$ROOTFS/proc" "$ROOTFS/dev" "$ROOTFS" 2>/dev/null || true
            rmdir  "$ROOTFS/club" "$ROOTFS" 2>/dev/null || true
        }
        trap cleanup EXIT

        mount --bind / "$ROOTFS" && mount --make-private "$ROOTFS"
        mount -t overlay overlay -o lowerdir="$ROOTFS",upperdir="$upper",workdir="$work" "$ROOTFS"
        mount --bind /proc    "$ROOTFS/proc"
        mount --bind /dev     "$ROOTFS/dev"
        mount --bind /tmp     "$ROOTFS/tmp"

        mkdir -p "$ROOTFS/club"
        mount --bind "$cdir" "$ROOTFS/club"

	    chroot "$ROOTFS" bash -c "cd /club/desktop && ./install.sh '$chapter' '$project' unsafe"
    ' _ "$upper" "$work" "$cdir" "$chapter" "$project"

    local res=$?
    (( res == 0 )) && ins_safe_end "$item" || say "Sandbox failed ($res)" "💥"
}

ins_safe_end() {
    local upper="$bdir/layers/$1/upper"
    
    find "$upper" -type f \( -name "*.so*" -o -executable \) -exec strip --strip-unneeded {} + 2>/dev/null
    
    local c_bin=$(find "$upper" -type f -executable ! -name "*.so*" 2>/dev/null | wc -l)
    local c_lib=$(find "$upper" -type f \( -name "*.so*" -o -path "*/lib/*" -o -path "*/lib64/*" \) 2>/dev/null | wc -l)
    local c_cfg=$(find "$upper" -type f -path "*/etc/*" 2>/dev/null | wc -l)
    local c_tot=$(find "$upper" -type f 2>/dev/null | wc -l)
    local c_ext=$(( c_tot - c_bin - c_lib - c_cfg ))
    (( c_ext < 0 )) && c_ext=0 
    
    local sz_kpi=$(cd "$upper" && du -h -d 2 2>/dev/null | awk '$2 != "." { sub(/^\.\//, "", $2); print $1, $2 }' | sort -hr | head -n 6 | awk '{printf "\033[1;33m%s\033[0m:%s  ", $2, $1}')
    
    echo -e "\n📊 Results $1"
    echo -e "  ├─ 📦 ⚙️ Prog: $c_bin, 📚 Libs: $c_lib, 📝 Cfg: $c_cfg, 🧩 Ext: $c_ext (Total: $c_tot)"
    echo -e "  └─ 💾 ${sz_kpi:-None}\n"
    
    say "Layer ready: $upper" "⏸️"
    read -rp "  [A]ll / [P]ackage / [U]upload / [I]nstall / [O]mit [A]: " a
    case "${a,,}" in
        p) tar -czf "$ldir/packages/$chapter-$1.tar.gz" -C "$upper" . ;;
        i) tar -c -C "$upper" . | sudo tar -x --overwrite --keep-directory-symlink -C / ;;
        o) return 0 ;;
        u)  tar -czf "$ldir/packages/$chapter-$1.tar.gz" -C "$upper" . 
            cat "$ldir/packages/$chapter-$1.tar.gz" | ssh $cdnhost "cat > $cdndir/$chapter-$1.tar.gz" ;;
        *) tar -czf "$ldir/packages/$chapter-$1.tar.gz" -C "$upper" .
           tar -c -C "$upper" . | sudo tar -x --overwrite --keep-directory-symlink -C / ;;
    esac
}

ins_packages() {
    
    local pkg_name="${1:-${chapter}-${project}}"
    local pkg_file="${pkg_name}.tar.gz"
    local url="$cdn/${1:-latest}/${pkg_file}"
    local local_path="$ldir/packages/${pkg_file}"
    local src=""
    local is_remote=0

    if curl -s --head --fail "$url" >/dev/null; then
        echo -e "☁️  Remote: \033[1;36m$url\033[0m"
        src="$url"
        is_remote=1
    elif [[ -f "$local_path" ]]; then
        echo -e "🖥️  Local: \033[1;33m$local_path\033[0m"
        src="$local_path"
    else
        echo -e "❌ Can't find \033[1;31m$pkg_file\033[0m"
        return 1
    fi

    read -rp "❓ Install $pkg_name? [S/n]: " ans
    if [[ "${ans,,}" == "n" ]]; then
        echo "⏸️  Install cancelled."
        return 0
    fi

    echo "🚀 Installing $pkg_name..."
    if (( is_remote )); then
        curl -s -L "$src" | sudo tar -xz --overwrite --keep-directory-symlink -C /
    else
        sudo tar -xzf "$src" --overwrite --keep-directory-symlink -C /
    fi
    
    echo -e "✅ \033[1;32mInstall complete.\033[0m"
}

. install/macro.sh
. install/$chapter.sh

case $mode in
    unsafe) 	ins_$project ;;
    once)   	ins_once ;;
    package) 	ins_packages $arg;;
    *)      	ins_safe ;;
esac
