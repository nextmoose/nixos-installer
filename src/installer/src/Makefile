build:

install: ${DESTDIR}/bin/installer

${DESTDIR}:
	mkdir "${@}"

${DESTDIR}/bin: ${DESTDIR}
	mkdir "${@}"

${DESTDIR}/bin/installer: installer.sh ${DESTDIR}/bin
	cp "${<}" "${@}"
	chmod 0500 "${@}"
	echo ${SCRIPT} > ${DESTDIR}/bin/script
