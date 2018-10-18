#!/bin/sh

STATUS=64 &&
    cleanup() {
	bash &&
	    (sudo VBoxManage unregistervm --delete nixos || true) &&
	    (sudo rm ${DESTDIR}/nixos.vmdk || true) &&
	    (sudo lvremove -f /dev/volumes/nixos || true) &&
	    (rm --recursive --force ${DESTDIR} || true) &&
	    exit ${STATUS} &&
	    true
    } &&
    trap cleanup EXIT &&
    mkdir ${DESTDIR} &&
    mkdir ${DESTDIR}/installation &&
    cp --recursive src/. ${DESTDIR}/installation &&
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
    read -p "IS IT OK? y/n" ISITOK &&
    [ "${ISITOK}" == "y" ] &&
    STATUS=0 &&
    true
