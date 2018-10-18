build: installer.sh properties.env

properties.env:
	echo GNUPG=${GNUPG} > "${@}"

install: ${DESTDIR}/scripts/installer.sh ${DESTDIR}/etc/properties.env ${DESTDIR}/bin/installer

${DESTDIR}:
	mkdir "${@}"

${DESTDIR}/scripts: ${DESTDIR}
	mkdir "${@}"

${DESTDIR}/scripts/installer.sh: installer.sh ${DESTDIR}/scripts
	cp "${<}" "${@}"

${DESTDIR}/etc: ${DESTDIR}
	mkdir "${@}"

${DESTDIR}/etc/properties.env: properties.env ${DESTDIR}/etc
	cp "${<}" "${@}"

${DESTDIR}/bin: ${DESTDIR}
	mkdir "${@}"

${DESTDIR}/bin/installer: installer.sh ${DESTDIR}/bin
	echo "#!/bin/sh" > "${@}"
	echo >> "${@}"
	echo "source ${DESTDIR}/etc/properties.env &&" >> "${@}"
	echo "sh ${DESTDIR}/scripts/installer.sh \${@}" >> "${@}"
	chmod 0500 "${@}"
