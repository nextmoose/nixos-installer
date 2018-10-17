all :

clean:
	rm --recursive --force build

build:
	mkdir build

build/iso.nix: src/iso.nix build
	cp "${<}" "${@}"
