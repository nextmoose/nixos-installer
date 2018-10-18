#!/bin/sh

STATUS=64 &&
    TEMP_DIR=$(mktemp -d) &&
    cleanup() {
	rm --recursive --force ${TEMP_DIR} &&
	    ((sudo VBoxManage controlvm nixos poweroff soft && sleep 10s) || true) && 
	    (sudo VBoxManage unregistervm --delete nixos || true) &&
	    (sudo rm ${DESTDIR}/nixos.vmdk || true) &&
	    (sudo lvremove -f /dev/volumes/nixos || true) &&
	    (rm --recursive --force ${DESTDIR} || true) &&
	    exit ${STATUS} &&
	    true
    } &&
    trap cleanup EXIT &&
    read -s -p "SYMMETRIC PASSPHRASE? " SYMMETRIC_PASSPHRASE &&
    if [ -z "${SYMMETRIC_PASSPHRASE}" ]
    then
	echo Blank SYMMETRIC PASSPHRASE &&
	    exit 70
    fi &&
    echo &&
    read -s -p "VERIFY SYMMETRIC PASSPHRASE? " VERIFY_SYMMETRIC_PASSPHRASE &&
    if [ "${SYMMETRIC_PASSPHRASE}" == "${VERIFY_SYMMETRIC_PASSPHRASE}" ]
    then
	echo Verified SYMMETRIC PASSPHRASE
    else
	echo Failed to verify SYMMETRIC PASSPHRASE &&
	    exit 71
    fi &&
    echo &&
    read -s -p "LUKS PASSPHRASE? " LUKS_PASSPHRASE &&
    if [ -z "${LUKS_PASSPHRASE}" ]
    then
	echo Blank LUKS PASSPHRASE &&
	    exit 72
    fi &&
    echo &&
    read -s -p "VERIFY LUKS PASSPHRASE? " VERIFY_LUKS_PASSPHRASE &&
    if [ "${LUKS_PASSPHRASE}" == "${VERIFY_LUKS_PASSPHRASE}" ]
    then
	echo Verified LUKS PASSPHRASE
    else
	echo Failed to verify LUKS PASSPHRASE &&
	    exit 73
    fi &&
    echo &&
    read -s -p "USER PASSWORD? " USER_PASSWORD &&
    if [ -z "${USER_PASSWORD}" ]
    then
	echo Blank USER PASSWORD &&
	    exit 74
    fi &&
    echo &&
    read -s -p "VERIFY USER PASSWORD? " VERIFY_USER_PASSWORD &&
    if [ "${USER_PASSWORD}" == "${VERIFY_USER_PASSWORD}" ]
    then
	echo Verified USER PASSWORD
    else
	echo Failed to verify USER PASSWORD &&
	    exit 75
    fi &&
    echo &&
    echo VERIFIED &&
    echo &&
    mkdir ${DESTDIR} &&
    mkdir ${DESTDIR}/installation &&
    cp --recursive src/. ${DESTDIR}/installation &&
    mkdir ${TEMP_DIR}/secrets &&
    echo "${LUKS_PASSPHRASE}" > ${TEMP_DIR}/secrets/luks.passphrase &&
    echo "${USER_PASSWORD}" > ${TEMP_DIR}/secrets/user.password &&
    tar --create --file ${TEMP_DIR}/secrets.tar --directory ${TEMP_DIR}/secrets/ . &&
    rm --recursive --force ${TEMP_DIR}/secrets &&
    gzip -9 --to-stdout ${TEMP_DIR}/secrets.tar > ${TEMP_DIR}/secrets.tar.gz &&
    rm --recursive --force ${TEMP_DIR}/secrets.tar &&
    echo "${SYMMETRIC_PASSPHRASE}" | gpg --batch --passphrase-fd 0 --output ${DESTDIR}/installation/installer/src/secrets.tar.gz.gpg --symmetric ${TEMP_DIR}/secrets.tar.gz &&
    rm --force ${TEMP_DIR}/secrets.tar &&
    (
	cd ${DESTDIR}/installation &&
	    nix-${DESTDIR} '<nixpkgs/nixos>' -A config.system.${DESTDIR}.isoImage -I nixos-config=iso.nix &&
	    true
    ) &&
    sudo lvcreate -y --name nixos --size 100G volumes &&
    sudo VBoxManage internalcommands createrawvmdk -filename ${DESTDIR}/nixos.vmdk -rawdisk /dev/volumes/nixos &&
    sudo VBoxManage createvm --name nixos --register &&
    sudo VBoxManage storagectl nixos --name "SATA Controller" --add SATA &&
    sudo VBoxManage storageattach nixos --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium build/installation/result/iso/nixos-18.03.133245.d16a7abceb7-x86_64-linux.iso &&
    sudo VBoxManage storagectl nixos --name "IDE" --add IDE &&
    sudo VBoxManage storageattach nixos --storagectl "IDE" --port 0 --device 0 --type hdd --medium ${DESTDIR}/nixos.vmdk &&
    sudo VBoxManage modifyvm nixos --memory 2000 &&
    sudo VBoxManage modifyvm nixos --nic1 nat &&
    sudo VBoxManage modifyvm nixos --firmware efi &&
    sudo VBoxManage startvm nixos &&
    read -p "IS IT OK? y/n " ISITOK &&
    [ "${ISITOK}" == "y" ] &&
    STATUS=0 &&
    true
