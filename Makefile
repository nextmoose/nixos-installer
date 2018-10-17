all: clean install

clean:
	sudo VBoxManage unregistervm --delete nixos || true
	sudo rm ${DESTDIR}/nixos.vmdk || true
	sudo lvremove -f /dev/volumes/nixos || true
	rm --recursive --force ${DESTDIR} || true

install: ${DESTDIR}/machine

${DESTDIR}:
	mkdir "${@}"

${DESTDIR}/installation: ${DESTDIR}
	mkdir "${@}"

${DESTDIR}/installation/iso.nix: src/iso.nix ${DESTDIR}/installation
	cp "${<}" "${@}"

${DESTDIR}/installation/installer: ${DESTDIR}/installation
	mkdir "${@}"

${DESTDIR}/installation/installer/default.nix: src/installer/default.nix ${DESTDIR}/installation/installer
	cp "${<}" "${@}"

${DESTDIR}/installation/installer/src: ${DESTDIR}/installation/installer
	mkdir "${@}"

${DESTDIR}/installation/installer/src/Makefile: src/installer/src/Makefile ${DESTDIR}/installation/installer/src
	cp "${<}" "${@}"

${DESTDIR}/installation/installer/src/hello.sh: src/installer/src/hello.sh ${DESTDIR}/installation/installer/src
	cp "${<}" "${@}"

${DESTDIR}/installation/result: ${DESTDIR}/installation/iso.nix ${DESTDIR}/installation/installer/default.nix ${DESTDIR}/installation/installer/src/Makefile ${DESTDIR}/installation/installer/src/hello.sh
	cd ${DESTDIR}/installation && nix-${DESTDIR} '<nixpkgs/nixos>' -A config.system.${DESTDIR}.isoImage -I nixos-config=iso.nix

${DESTDIR}/nixos.vmdk: ${DESTDIR}
	sudo lvcreate -y --name nixos --size 100G volumes
	sudo VBoxManage internalcommands createrawvmdk -filename ${DESTDIR}/nixos.vmdk -rawdisk /dev/volumes/nixos

${DESTDIR}/machine: ${DESTDIR}/installation/result ${DESTDIR}/nixos.vmdk
	sudo VBoxManage createvm --name nixos --register
	sudo VBoxManage storagectl nixos --name "SATA Controller" --add SATA
	sudo VBoxManage storageattach nixos --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
	sudo VBoxManage storagectl nixos --name "IDE" --add IDE
	sudo VBoxManage storageattach nixos --storagectl "IDE" --port 0 --device 0 --type hdd --medium ${DESTDIR}/nixos.vmdk
	sudo VBoxManage modifyvm nixos --memory 2000
	sudo VBoxManage modifyvm nixos --nic1 nat
	sudo VBoxManage modifyvm nixos --firmware efi
	touch ${@}
