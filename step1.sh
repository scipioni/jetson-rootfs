#!/bin/bash


##########
echo "Check root permission"

if [ "x$(whoami)" != "xroot" ]; then
	echo "This script requires root privilege!!!"
	exit 1
fi

##########
echo "Get environment"

source .env



##########
echo "Set script options"

set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

##########
echo "Install tools"

# apt install -y --no-install-recommends \
#     qemu-user-static \
#     debootstrap \
#     binfmt-support \
#     libxml2-utils

##########
echo "Debootstrap a base"

# create a zip file for laster use
# delete the zip file to get new version of packages
# however, app packages will be updated later
if [ ! -f ${ARCH}-${RELEASE}.tgz ]
then
    sudo rm -fR ${ROOT_DIR}
    echo "Download packages to ${ARCH}-${RELEASE}.tgz"
    debootstrap \
        --verbose \
        --no-check-gpg \
        --make-tarball=${ARCH}-${RELEASE}.tgz \
        --arch=${ARCH} \
        ${RELEASE} \
        ${ROOT_DIR} \
        ${REPO}
fi

        #--keyring=ubuntu-archive-keyring.gpg \
        #--foreign \

echo "Install packages from ${ARCH}-${RELEASE}.tgz"
debootstrap \
    --verbose \
    --foreign \
    --no-check-gpg \
    --unpack-tarball=$(realpath ${ARCH}-${RELEASE}.tgz) \
    --arch=${ARCH} \
    ${RELEASE} \
    ${ROOT_DIR} \
    ${REPO}

#[ -f rootfs/tmp/cuda-keyring_1.0-1_all.deb   ] ||  https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/arm64/cuda-keyring_1.0-1_all.deb

sudo rsync -rv overlay/ rootfs/

##########


# qemu-aarch64-static will be called by chroot
install -Dm755 $(which qemu-aarch64-static) ${ROOT_DIR}/usr/bin/qemu-aarch64-static

# ubuntu-keyring package can be installed, but this way is a bit faster ?
#install -Dm644 ubuntu-archive-keyring.gpg ${ROOT_DIR}/usr/share/keyrings/ubuntu-archive-keyring.gpg

##########
echo "Unpack ${ROOT_DIR}"

chroot ${ROOT_DIR} /debootstrap/debootstrap --second-stage

# sudo systemd-nspawn -bD rootfs/

# jetson-gpio-common

# chroot /stable-chroot /usr/bin/apt install locales
# sed -i '/en_GB.UTF-8/s/^# //;/en_US.UTF-8/s/^# //' /stable-chroot/etc/locale.gen
# chroot /stable-chroot /usr/sbin/locale-gen
# echo -e 'LANG=en_GB.UTF-8\nLANGUAGE=en_GB.UTF-8' > /stable-chroot/etc/default/locale