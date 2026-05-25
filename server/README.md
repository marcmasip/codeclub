# 🌐 codeclub v.3 *Server Edition !*

A minimalist Linux host for containerized workloads.
Stack: Kernel, Busybox, ZFS, Git, Docker.

# Users
Friends and Projects are provisioned with purpose-tuned ZFS datasets:
- ~/file (64k)     - General storage
- ~/db (16k)       - Databases
- ~/log (1M)       - High-throughput logs
- ~/checkout (128k)- Source code

# Project API
Projects adhere to a unified lifecycle convention defined in shell scripts.
The interface is defined and implemented by let's say *project.sh* :

```
CMD="${1:-start}"
case "$CMD" in
	stop|build|start) "${CMD}_${2:-all}" ;;  
    *) echo "uso: $0 <start|stop|build> <service|all>"; exit 1 ;;
esac
```

Implementation: Define your logic in functions like start_<service>, stop_<service>, and build_<service>. You must implement _all variants.

Configuration: Environments are versioned as <env>.sh entry points. They inject variables before sourcing the main script:

```
RUN_ARGS="-v /persit:/data -p 20:20"
. project.sh
```

# Publication
The vhosts project runs Traefik to manage routing and SSL certificates. 
Projects receive external traffic by applying Docker labels with the target domain.

# Backups
User datasets are snapshotted daily and synced to remote devices.

# Host details
The host is configured by
- /sbin/init 
- /etc/init/start/<priority>_item.sh
- /etc/init/stop/<priority>_item.sh
- /etc/init/enable/<priority>_daemon.sh
- /etc/init/backup/{daily,1-snapshot,2-sync}.sh
- /etc/init/shutdown.sh [reboot|shutdown]
- /etc/init/projects.sh [start|stop]
- /etc/init/service.sh # helper for enable/ items
- /etc/init/watch.sh # checks enable/ items and restarts

## sbin/init
Executes the start sequence, sets up maintenance TTYs, and enters a reaper mode loop (cleaning up zombie processes).

## /etc/init/start
Boot scripts executed in lexical order:
- 1-sys.sh
Mounts system filesystems, provides rescue mode fallback.
- 20-network.sh
Configures DHCP and asserts network time (NTP).
- 30-data.sh
Imports ZFS pools and mounts datasets.
- 50-services.sh
Triggers watch.sh to launch daemons (eg. sshd, dockerd).
- 99-projects.sh
Invokes projects.sh start to spin up user containers.

## /etc/init/enable/
Contains executable scripts that register daemons. The supervisor (watch.sh) checks these files. If a service is down (missing PID), it restarts. If failures are excessive, the file is moved to /etc/init/error to prevent infinite loops.

```
#!/bin/sh
service_name="Secure Shell Host"

service_start() {
   /usr/sbin/sshd -e -D &
   echo "$!" > "$PID_FILE"
}

. "/etc/init/service.sh"
```

# Source
The target architecture is x86_64, based on /desktop.
The build process starts from this base, selecting and stripping a limited set of binaries.

The server/ directory contains setup scripts:
- server/disk.sh <create|mount|umount|join>: Creates and manages the development disk and chroot environment.
- server/binpick.sh <source> <dest-sysroot>: Selects and copies required binaries into the target sysroot.

System behavior is defined through shell scripts: (WIP)
- server/etc/init/: Core system initialization scripts.
- server/etc/backup/: Backup and recovery scripts.
- server/prepare/binpick.sh <source> <dest-sysroot>: Selects and copies required binaries into the target sysroot.

