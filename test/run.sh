#!/usr/bin/env bash

set -xeuo pipefail

gitdir="$(git rev-parse --show-toplevel)"
userhost="root@127.0.0.1"
port="60022"
cache_dir="$PWD/cache"
ssh_key="$cache_dir/id_rsa"
ssh_opts=(
	-i "$ssh_key"
	-o StrictHostKeyChecking=no
	-o UserKnownHostsFile=/dev/null
)

exec_ssh() {
	ssh \
		"${ssh_opts[@]}" \
		-p "$port" \
		"$userhost" \
		"$@"
}

cp_ssh() {
	from=("${@:1:$#-1}")
	to="${@:$#}"

	scp \
		"${ssh_opts[@]}" \
		-r \
		-P "$port" \
		"${from[@]}" \
		"$userhost:$to"
}

exec_ssh mount -o remount,size=2G /run/archiso/cowspace
exec_ssh pacman --noconfirm -Sy

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
	"$gitdir/test/mkinitcpio.conf" \
	/root/arch-ostree/test/

cp_ssh "${ssh_key}.pub" /tmp/

exec_ssh /root/arch-ostree/test/install_from_live
