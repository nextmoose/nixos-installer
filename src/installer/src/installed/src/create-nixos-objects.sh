#!/bin/sh

while [ "${#}" -gt 0 ]
do
    case "${1}" in
	--root)
	    ROOT="${2}" &&
		shift 2 &&
		true
	    ;;
	*)
	    echo Unknown Option &&
		echo "${1}" &&
		echo "${0}" &&
		echo "${@}" &&
		exit 65 &&
		true
	    ;;
    esac &&
	true
done &&
    find "${ROOT}" -name *.d | while read DIRECTORY
    do
	if [ -d "${DIRECTORY}" ] && [ ! -f "${DIRECTORY%.*}.nix" ]
	then
	    cat "${STORE_DIR}/etc/head.txt" > "${DIRECTORY%.*}.nix" &&
		ls -1 "${DIRECTORY}" | while read FILE
		do
		    echo "  ${FILE%.*} = (import ./$(basename ${DIRECTORY})/${FILE%.*}.nix { inherit pkgs; });" >> "${DIRECTORY%.*}.nix" &&
			true
		done &&
		cat "${STORE_DIR}/etc/tail.txt" >> "${DIRECTORY%.*}.nix" &&
		true
	fi &&
	    true
    done &&
    true
