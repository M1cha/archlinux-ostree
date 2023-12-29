#!/usr/bin/env bash

set -xeuo pipefail

gitdir="$(git rev-parse --show-toplevel)"
userhost="root@127.0.0.1"
port="60022"

exec_ssh() {
	ssh -p "$port" "$userhost" "$@"
}

cp_ssh() {
	from=("${@:1:$#-1}")
	to="${@:$#}"

	scp -r -P "$port" "${from[@]}" "$userhost:$to"
}

exec_ssh rm -rf /root/arch-ostree
exec_ssh mkdir /root/arch-ostree
cp_ssh \
	"$gitdir/arch-ostree" \
	"$gitdir/lib" \
	"$gitdir/share" \
	/root/arch-ostree/

exec_ssh mkdir /root/arch-ostree/test
cp_ssh \
	"$gitdir/test/build_rootfs.sh" \
	"$gitdir/test/install_from_live" \
	"$gitdir/test/layout.sfdisk" \
	/root/arch-ostree/test/

exec_ssh /root/arch-ostree/test/install_from_live
