all:

install: $out/bin/hello

$out:
	mkdir "${@}"

$out/bin: $out
	mkdir "${@}"

$out/bin/hello: hello.sh $out/bin
	cp "${<}" "${@}"
	chmod 0500 "${@}"
