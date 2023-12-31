packages=(
	# The basics as usual.
	base
	# We need a kernel, of source.
	linux
	# Microcode updates for multiple CPUs, so this rootfs can work on all
	# of them.
	intel-ucode
	amd-ucode

	# All of these are needed to be able to use `ostree deploy` with GRUB.
	efibootmgr
	grub
	ostree
	which
)
aur_packages=(
	yay-bin
)

prepare() {
	# We need the ostree hook.
	install -d "$rootfs/etc"
	install -m 0644 mkinitcpio.conf "$rootfs/etc/"
}

# This is needed to be able to install AUR packages.
post_install_early() {
	echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist
	pacman-key --init
	pacman-key --populate
}

post_install() {
	# The rootfs can't be modified and systemd can't create them implicitly.
	# That's why we have to create them as part of the rootfs.
	mkdir /efi

	ln -sf /usr/share/zoneinfo/UTC /etc/localtime
	sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen

	locale-gen
	systemctl enable systemd-timesyncd.service
}
