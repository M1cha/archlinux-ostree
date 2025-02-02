FROM docker.io/alpine:3.21 AS builder

RUN apk add --no-cache coreutils gnupg tar wget zstd

WORKDIR /tmp

RUN wget http://mirror.cmt.de/archlinux/iso/latest/b2sums.txt
RUN wget http://mirror.cmt.de/archlinux/iso/latest/sha256sums.txt
RUN wget http://mirror.cmt.de/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.zst
RUN wget http://mirror.cmt.de/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.zst.sig
RUN gpg --auto-key-locate clear,wkd -v --locate-external-key pierre@archlinux.org

# This might be pedantic given that the signature matches, but why not.
RUN b2sum --ignore-missing -c b2sums.txt
RUN sha256sum --ignore-missing -c sha256sums.txt
RUN gpg --keyserver-options auto-key-retrieve --verify archlinux-bootstrap-x86_64.tar.zst.sig archlinux-bootstrap-x86_64.tar.zst

WORKDIR /

RUN mkdir /rootfs
RUN tar xf /tmp/archlinux-bootstrap-x86_64.tar.zst --numeric-owner -C /rootfs

FROM scratch
COPY --from=builder /rootfs/root.x86_64 /

# The bootstrap image is very minimal and we still have to setup pacman.
RUN pacman-key --init
RUN pacman-key --populate
RUN echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist

# This allows us to use this image for committing as well.
RUN pacman --noconfirm -Syu grub ostree rsync

# This allows using this container to make a deployment.
RUN ln -s sysroot/ostree /ostree

# This allows using pacstrap -N in a rootless container.
RUN echo 'root:1000:5000' > /etc/subuid
RUN echo 'root:1000:5000' > /etc/subgid
