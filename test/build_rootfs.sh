packages=(
	base
	linux
	intel-ucode
	amd-ucode

	efibootmgr
	grub
	ostree
	which

	btrfs-progs
	openssh
)

prepare() {
	install -d "$rootfs/etc"
	#install -m 0644 mkinitcpio.conf "$rootfs/etc/"

	install -d "$rootfs/root/.ssh"
	#install -m 0644 "~/.ssh/id_rsa.pub" "$rootfs/root/.ssh/authorized_keys"
}

post_install_early() {
	echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist
	pacman-key --init
	pacman-key --populate
}

post_install() {
	ln -sf /usr/share/zoneinfo/UTC /etc/localtime
	sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen

	locale-gen
	systemctl enable sshd.service
	systemctl enable systemd-timesyncd.service
}
