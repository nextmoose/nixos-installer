#!/bin/sh

TEMP_DIR=$(mktemp -d) &&
    cleanup() {
	echo ${PATH} &&
	    rm --recursive --force ${TEMP_DIR} &&
	    true
    } &&
    trap cleanup EXIT &&
    while [ "${#}" -gt 0 ]
    do
	case "${1}" in
	    --upstream-url)
		UPSTREAM_URL="${2}" &&
		    shift 2 &&
		    true
		;;
	    --upstream-branch)
		UPSTREAM_BRANCH="${2}" &&
		    shift 2 &&
		    true
		;;
	    --wifi-ssid)
		WIFI_SSID="${2}" &&
		    shift 2 &&
		    true
		;;
	    --wifi-password)
		WIFI_PASSWORD="${2}" &&
		    shift 2 &&
		    true
		;;
	    *)
		echo Unsupported Option &&
		    echo ${1} &&
		    echo ${0} &&
		    echo ${@} &&
		    exit 65 &&
		    true
		;;
	esac
    done &&
    (cat <<EOF
UPSTREAM_URL
UPSTREAM_BRANCH
WIFI_SSID
EOF
    ) | while read VAR
    do
	eval VAL=\${${VAR}} &&
	    if [ -z "${VAR}" ]
	    then
		echo Unspecified ${VAR} &&
		    exit 66 &&
		    true
	    fi &&
	    true
    done &&
    read -s -p "WIFI PASSWORD? " WIFI_PASSWORD &&
    wpa_passphrase "${WIFI_SSID}" "${WIFI_PASSWORD}" | wpa_supplicant -B -i wlo1 -c &&
    read -s -p "SYMMETRIC PASSPHRASE? " SYMMETRIC_PASSPHRASE &&
    echo "${SYMMETRIC_PASSPHRASE}" | gpg --batch --passphrase-fd 0 --output ${TEMP_DIR}/secrets.tar.gz ${STORE_DIR}/etc/secrets.tar.gz.gpg &&
    gunzip --to-stdout ${TEMP_DIR}/secrets.tar.gz > ${TEMP_DIR}/secrets.tar &&
    mkdir ${TEMP_DIR}/secrets &&
    tar --extract --file ${TEMP_DIR}/secrets.tar --directory ${TEMP_DIR}/secrets &&
    source ${TEMP_DIR}/secrets/installer.env &&
    (swapoff -L SWAP || true ) &&
    (umount /mnt/nix || true) &&
    (umount /mnt/boot || true) &&
    (umount /mnt || true) &&
    (cryptsetup luksClose /dev/mapper/root || true) &&
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


+264G

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
    echo y | mkfs.ext4 -L ROOT /dev/mapper/root &&
    mount /dev/mapper/root /mnt &&
    mkdir /mnt/boot &&
    mount /dev/sda1 /mnt/boot/ &&
    swapon -L SWAP &&
    mkdir /mnt/etc &&
    mkdir /mnt/etc/nixos &&
    HASHED_USER_PASSWORD=$(echo -n ${USER_PASSWORD} | mkpasswd --stdin -m sha-512) &&
    cp --recursive ${STORE_DIR}/etc/installed /mnt/etc/nixos &&
    (cat > /mnt/etc/nixos/installed/password.nix <<EOF
{ config, pkgs, ... }:
{
  users.extraUsers.user.hashedPassword = "${HASHED_USER_PASSWORD}";
}
EOF
    ) &&
    mkdir ${TEMP_DIR}/configuration &&
    git -C ${TEMP_DIR}/configuration init &&
    git -C ${TEMP_DIR}/configuration remote add upstream "${UPSTREAM_URL}" &&
    git -C ${TEMP_DIR}/configuration remote set-url --push upstream no_push &&
    git -C ${TEMP_DIR}/configuration fetch upstream "${UPSTREAM_BRANCH}" &&
    git -C ${TEMP_DIR}/configuration checkout "upstream/${UPSTREAM_BRANCH}" &&
    if [ -f ${TEMP_DIR}/configuration/configuration.nix ]
    then
	cp ${TEMP_DIR}/configuration/configuration.nix /mnt/etc/nixos
    fi &&
    if [ -d ${TEMP_DIR}/configuration/custom ]
    then
	rsync --verbose --recursive ${TEMP_DIR}/configuration/custom /mnt/etc/nixos
    fi &&
    if [ -f ${TEMP_DIR}/configuration/install.sh ]
    then
	sh ${TEMP_DIR}/configuration/install.sh
    fi &&
    true
    PATH=/run/current-system/sw/bin nixos-generate-config --root /mnt &&
    PATH=/run/current-system/sw/bin nixos-install --root /mnt --no-root-passwd &&
    true
