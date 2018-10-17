build:

install: ${DESTDIR}/bin/hello
	env

${DESTDIR}:
	mkdir "${@}"

${DESTDIR}/bin: ${DESTDIR}
	mkdir "${@}"

${DESTDIR}/bin/hello: hello.sh ${DESTDIR}/bin
	cp "${<}" "${@}"
	chmod 0500 "${@}"
