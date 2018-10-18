#!/bin/sh

TEMP_DIR=$(mktemp -d) &&
    cleanup() {
	echo ${TEMP_DIR} &&
	    bash &&
	    rm --recursive --force ${TEMP_DIR} &&
	    true
    } &&
    trap cleanup EXIT &&
    read -s -p "SYMMETRIC PASSWORD? " SYMMETRIC_PASSWORD &&
    echo "${SYMMETRIC_PASSWORD}" | gpg --batch --passphrase-fd 0 --output ${TEMP_DIR}/secrets.tar ${STORE_DIR}/secrets.tar.gpg &&
    tar --extract --file ${TEMP_DIR}/secrets.tar --directory ${TEMP_DIR}/secrets &&
    source ${TEMP_DIR}/secrets/installer.env &&
    rm --force ${TEMP_DIR}/secrets/installer.env &&
    (swapoff -L SWAP || true ) &&
    (umount /mnt/nix || true) &&
    (umount /mnt/boot || true) &&
    (umount /mnt || true) &&
    lvs --options NAME volumes | tail -n -1 | while read NAME
    do
	wipefs --all /dev/volumes/${NAME} &&
	    (lvremove --force /dev/volumes/${NAME} || true)
    done &&
    (vgremove --force /dev/volumes || true) &&
    (pvremove --force /dev/volumes || true) &&
    echo p | gdisk /dev/sda | grep "^\s*[0-9]" | sed -e "s#^\s*##" -e "s#\s.*\$##" | while read I
    do
	wipefs --all /dev/sda${I} &&
	    (cat <<EOF
d
${I}
w
y
EOF
	    ) | gdisk /dev/sda
    done &&
    (cat <<EOF
n


+200M
EF00
n


+8G
8200
n


+64G

n



8E00
w
Y
EOF
    ) | gdisk /dev/sda &&
    mkfs.vfat -F 32 -n BOOT /dev/sda1 &&
    mkswap -L SWAP /dev/sda2 &&
    echo -n "${LUKS_PASSPHRASE}" | cryptsetup --key-file - luksFormat /dev/sda3 &&
    echo -n "${LUKS_PASSPHRASE}" | cryptsetup --key-file - luksOpen /dev/sda3 root &&
    echo y | mkfs.ext4 -L ROOT /dev/sda3 &&
    mount /dev/mapper/root /mnt &&
    mkdir /mnt/boot &&
    mount /dev/sda1 /mnt/boot/ &&
    swapon -L SWAP &&
    mkdir /mnt/etc &&
    mkdir /mnt/etc/nixos &&
    (cat > /mnt/etc/nixos/password.nix <<EOF
{ config, pkgs, ... }:
{
  users.extraUsers.user.hashedPassword = "$(echo ${USER_PASSWORD} | mkpasswd --stdin -m sha-512)";
}
EOF
    ) &&  
    mkdir /mnt/etc/nixos/installed &&
    mkdir /mnt/etc/nixos/installed/secrets &&
    mkdir /mnt/etc/nixos/installed/secrets/src &&
    mv ${TEMP_DIR}/secrets.tar /mnt/etc/nixos/installed/secrets/src &&
    nixos-generate-config --root /mnt &&
    true

