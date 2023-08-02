FROM docker.io/archlinux:latest

RUN pacman --noconfirm -Sy \
    arch-install-scripts \
    base-devel \
    devtools \
    git \
    sd \
    sudo \
    ostree

RUN useradd -m builder
RUN echo 'builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/builder

# This allows them to run in a rootless podman container
RUN sed -i \
    -e 's|chroot_add_mount sys .*|chroot_add_mount --rbind \/sys "$1\/sys" \&\&|g' \
    -e 's|chroot_add_mount udev .*|chroot_add_mount --rbind /dev "$1/dev" \&\&|g' \
    -e 's|chroot_add_mount devpts .*||g' \
    -e 's|chroot_add_mount shm .*||g' \
    /usr/bin/{pacstrap,arch-chroot}
