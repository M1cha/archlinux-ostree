packages=(
	base
	amd-ucode
	intel-ucode
	linux-zen
	linux-firmware
	linux-zen-headers
	btrfs-progs grub
	ostree
	which
	efibootmgr
)

prepare() {
	install -D -m 0644 mkinitcpio.conf "$rootfs/etc/mkinitcpio.conf"
}

post_install() {
	echo hello
	passwd root
	true
}
