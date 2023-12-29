#!/usr/bin/env bash

set -euo pipefail

disk_file="$PWD/disk.qcow2"
mirror="https://geo.mirror.pkgbuild.com/iso"
iso="$PWD/arch.iso"
iso_unverified="$PWD/arch-unverified.iso"
ovmf_vars="$PWD/OVMF_VARS.4m.fd"

if [ ! -f "$iso" ]; then
	if [ ! -f "$iso_unverified" ]; then
		curl \
			-Lo "$iso_unverified" \
			"$mirror/latest/archlinux-x86_64.iso"
	fi
	if [ ! -f "$iso_unverified.sig" ]; then
		curl \
			-Lo "$iso_unverified.sig" \
			"$mirror/latest/archlinux-x86_64.iso.sig"
	fi

	sq --force wkd get pierre@archlinux.org -o release-key.pgp
	sq verify \
		--signer-file release-key.pgp \
		--detached "$iso_unverified.sig" \
		"$iso_unverified"

	mv arch-unverified.iso "$iso"
fi

rm -f "$disk_file"
qemu-img create -f qcow2 "$disk_file" 10G
cp /usr/share/edk2/x64/OVMF_VARS.4m.fd "$ovmf_vars"

qemu-system-x86_64 \
	-cdrom "$iso" \
	-drive file=cloud-init.iso,format=raw \
	-drive file="$disk_file,format=qcow2" \
	-enable-kvm \
	-cpu host \
	-drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
	-drive if=pflash,format=raw,file=$ovmf_vars \
	-m 2G \
	-nic user,hostfwd=tcp::60022-:22 \
	-nographic
