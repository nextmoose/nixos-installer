build: installer

installer: installer.sh
	sed -e "s#\${GNUPG}#${GNUPG}#" -e "winstaller" installer.sh

install: ${DESTDIR}/bin/installer

${DESTDIR}:
	mkdir "${@}"

${DESTDIR}/bin: ${DESTDIR}
	mkdir "${@}"

${DESTDIR}/bin/installer: installer ${DESTDIR}/bin
	cp "${<}" "${@}"
	chmod 0500 "${@}"
	echo ${SCRIPT} > ${DESTDIR}/bin/script
