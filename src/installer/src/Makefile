all:

install: ${SHELL}/bin/hello

${SHELL}:
	mkdir "${@}"

${SHELL}/bin: ${SHELL}
	mkdir "${@}"

${SHELL}/bin/hello: hello.sh ${SHELL}/bin
	cp "${<}" "${@}"
	chmod 0500 "${@}"
