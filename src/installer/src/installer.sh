#!/bin/sh

TEMP_DIR=$(mktemp -d) &&
    cleanup() {
	rm --recursive --force ${TEMP_DIR} &&
	    true
    } &&
    trap cleanup EXIT &&
    while [ "${#}" -gt 0 ]
    do
	case "${1}" in
	    --configuration-url)
		CONFIGURATION_URL="${2}" &&
		    shift 2
		;;
	    --configuration-branch)
		CONFIGURATION_BRANCH="${2}" &&
		    shift 2
		;;
	    *)
		echo Unsupported Option &&
		    echo ${1} &&
		    echo ${0} &&
		    echo ${@} &&
		    exit 65
		;;
	esac
    done &&
    read -s -p "SYMMETRIC PASSPHRASE? " SYMMETRIC_PASSPHRASE &&
    echo "${SYMMETRIC_PASSPHRASE}" | gpg --batch --passphrase-fd 0 --output ${TEMP_DIR}/secrets.tar.gz ${STORE_DIR}/etc/secrets.tar.gz.gpg &&
    gunzip --to-stdout ${TEMP_DIR}/secrets.tar.gz > ${TEMP_DIR}/secrets.tar &&
    mkdir ${TEMP_DIR}/secrets &&
    tar --extract --file ${TEMP_DIR}/secrets.tar --directory ${TEMP_DIR}/secrets &&
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
    LUKS_PASSPHRASE="$(cat ${TEMP_DIR}/secrets/luks.passphrase)" &&
    echo -n "${LUKS_PASSPHRASE}" | cryptsetup --key-file - luksFormat /dev/sda3 &&
    echo -n "${LUKS_PASSPHRASE}" | cryptsetup --key-file - luksOpen /dev/sda3 root &&
    echo y | mkfs.ext4 -L ROOT /dev/mapper/root &&
    mount /dev/mapper/root /mnt &&
    mkdir /mnt/boot &&
    mount /dev/sda1 /mnt/boot/ &&
    swapon -L SWAP &&
    mkdir /mnt/etc &&
    mkdir /mnt/etc/nixos &&
    USER_PASSWORD="$(cat ${TEMP_DIR}/secrets/user.password)" &&
    (cat > /mnt/etc/nixos/password.nix <<EOF
{ config, pkgs, ... }:
{
  users.extraUsers.user.hashedPassword = "$(echo ${USER_PASSWORD} | mkpasswd --stdin -m sha-512)";
}
EOF
    ) &&
    cp --recursive ${STORE_DIR}/etc/installed /mnt/etc/nixos &&
    mv ${TEMP_DIR}/secrets.tar /mnt/etc/nixos/installed/secrets/src &&
    if [ ! -z "${CONFIGURATION_REMOTE}" ] && [ ! -z "${CONFIGURATION_BRANCH}" ]
    then
	mkdir ${TEMP_DIR}/configuration &&
	    git -C ${TEMP_DIR}/configuration init &&
	    git -C ${TEMP_DIR}/configuration remote add origin "${CONFIGURATION_REMOTE}" &&
	    git -C ${TEMP_DIR}/configuration fetch origin "${CONFIGURATION_BRANCH}" &&
	    git -C ${TEMP_DIR}/configuration checkout "origin/${CONFIGURATION_BRANCH}" &&
	    rsync --verbose --recursive ${TEMP_DIR}/configuration/. /mnt/etc/nixos &&
	    true
    fi &&
    nixos-generate-config --root /mnt &&
    true
