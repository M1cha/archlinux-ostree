# Arch Linux bootc container builder

These scripts create a bootable archlinux ostree "tree". You can enjoy the same
features as distributions like Fedora Silverblue or Kinoite. Namely: readonly
rootfs, atomic updates and /etc merging and diffing.

If you think that it makes sense to turn this into a tool, so generic parts
can be reused: I'm open to that. But right now this repository is very specific
to my personal setup.

## Why?
I like to declaratively define my installation so I can document what I did and
why. It also allows me to quickly recreate the same setup on a different device.
Additionally, I like the readonly nature since my system tends to get filled
with untracked files when I'm not using ostree.

I thought about using NixOS. Conceptionally, it looks really good but I want to
keep using arch and the AUR for now. I might consider switching in future.

## First deployment

Install an ostree based distro, so you don't have to setup partition tables and
bootloaders yourself. I choose Fedora Kinoite because it uses btrfs and has an
installer that allows setting up full disk encryption.

If you want, you can delete the fedora OS from the ostree repo after the
installation. Personally, I decided to keep it around so I can use it to update
the bootloader (which is part of their normal rpm-ostree update process).

```bash
# ./update
# ostree admin os-init archlinux
# ostree admin deploy --os=archlinux --no-merge archlinux/latest
```

## Before the first boot
### extend grub.cfg
On arch, ostree will use `ostree-grub-generator` instead of `grub2-mkconfig`.
Additionally, that generator creates a config that expects the root partition
to be configured already. So we need to set the variables `boot` and `root` in
`/boot/efi/EFI/fedora/grub.cfg`:

```bash
search --no-floppy --fs-uuid --set=root {UUID}
search --no-floppy --fs-uuid --set=boot {UUID}
```

### kargs
Add the following to `/boot/loader/entries/ostree-*-archlinux.conf`:
- rootfs and encryption related options copied from fedora
  (`rd.luks.uuid`, `root`, `rootflags`, `rw`)
- `lsm=landlock,lockdown,yama,integrity,apparmor,bpf`

### Copy fstab and crypttab from fedora
```bash
cp /etc/{fstab,crypttab} /ostree/deploy/archlinux/deploy/*/etc/
```

If you want to use a separate `/var` partition instead of sharing it with
fedora, create a subvolume and replace the subvol name in your fstab:
```bash
mount /dev/mapper/luks-* /mnt
btrfs subvolume create /mnt/var-archlinux
umount /mnt
```

### Password
Change the root password in `/ostree/deploy/archlinux/deploy/*/etc/shadow` so
you can log in on the first boot.


## During the first boot
### hwclock

```bash
hwclock --systohc
```

### Change hostname
`/etc/hostname`

### Create user

```bash
useradd -m m1cha
passwd m1cha
```

## Update

```bash
$ ./update
# ostree admin deploy --os=archlinux archlinux/latest
```
