#!/usr/bin/env bash
#--------------------------------------------
# Default Bash Script Header
# recent changes based on https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail
trap stacktrace EXIT ERR
function stacktrace {
	if [ $? != 0 ]; then
		echo -e "\nThe command '$BASH_COMMAND' triggerd a stacktrace:"
		for i in $(seq 1 $((${#FUNCNAME[@]} - 2))); do j=$(($i+1)); echo -e "\t${BASH_SOURCE[$i]}: ${FUNCNAME[$i]}() called in ${BASH_SOURCE[$j]}:${BASH_LINENO[$i]}"; done
	fi
}

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
#--------------------------------------------
#. "$SCRIPT_DIR/lib.sh"
cd "$SCRIPT_DIR"

directory="$(pwd)/dev-build"
autoreconf --install
./configure --prefix="$directory" --datadir="$directory/share" --sysconfdir="$directory/etc"
make
make install
