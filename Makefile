all: build/installation/result build/nixos.vmdk

clean:
	sudo rm build/nixos.vmdk
	sudo lvremove -f /dev/volumes/nixos
	rm --recursive --force build

build:
	mkdir build

build/installation: build
	mkdir "${@}"

build/installation/iso.nix: src/iso.nix build/installation
	cp "${<}" "${@}"

build/installation/result: build/installation/iso.nix
	cd build/installation && nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix

build/nixos.vmdk:
	sudo lvcreate -y --name nixos --size 100G volumes
	sudo VBoxManage internalcommands createrawvmdk -filename build/nixos.vmdk -rawdisk /dev/volumes/nixos
