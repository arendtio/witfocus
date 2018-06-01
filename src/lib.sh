#!/usr/bin/env sh

function usage {
	local cmd="$1"
	local action="$2"

	echo -e "Task File '$action' does not exist.\n"
	echo -e "Usage: $cmd [operation] [options]"
	echo -e "Operations:"
	echo -e "\tbacklog\topens the backlog"
	echo -e "\tlast\topens the file for the last cycle (e.g. yesterday)"
	echo -e "\tcurrent\topens the file for the current cycle (e.g. today)"
	echo -e "\tnext\topens the file for the last cycle (e.g. tomorrow)"
	echo -e "\t{date}\topens the file for a specific date (e.g. use '2018-05-25' for the 25th May 2018)"
	echo -e ""
	echo -e "'current' is the default operation"
	echo -e ""
	echo -e "Options:"
	echo -e "\t-f\t to create non-existing files which are not part of the predefined operations (e.g. for future dates)"
	echo -e ""
	echo -e "For all operations which are not the 'current' one, the 'current' operation will be displayed next to it."
}

function setup {
	local pkgdatadir="$1"
	local sysconfig="$2"
	local userconfig="$3"

	# load system default
	local directory="$(loadConfigValueEvaluated "directory" "$XDG_DATA_HOME/taskfocus" "$sysconfig" "$userconfig")"

	echo "It looks like you are running taskfocus for the first time. Starting setup:"
	read -e -p "Please enter where to store your task files: " -i "$directory" directory;
	echo "directory: $directory" > "$userconfig"
	echo "vimrc snippet:"
	cat "$pkgdatadir/templates/vimrc"
	echo "It is recommended to add the above snippet to your vimrc."
	read -p "Should we append it for you now? (y/n)" -n 1 -r
	echo # move to a new line
	if [[ $REPLY = "y" ]]; then
		echo "Adding snippet to ~/.vimrc"
		cat "$pkgdatadir/templates/vimrc" >> ~/.vimrc
	fi
}

function colonValue {
	local field=$1
	local file=$2

	if ! [ -f "$file" ]; then
		return
	fi

	grep -e "^$field:" "$file" \
		| cut -d':' -f2- \
		| sed 's/\(^[[:space:]]\+\|[[:space:]]\+$\)//g'
}

function loadConfigValue {
	local field="$1"
	local defaultValue="$2"
	local systemConfig="$3"
	local userConfig="$4"

	# read from userconfig
	local value="$(colonValue "$field" "$userConfig")"
	if [ "$value" == "" ]; then
		value="$(colonValue "$field" "$systemConfig")"
	fi
	if [ "$value" == "" ]; then
		value="$defaultValue"
	fi
	echo "$value"
}

function loadConfigValueEvaluated {
	local value="$(loadConfigValue "$@")"
	eval "echo $value" # to evaluate variables like: $XDG_DATA_HOME
}

function fileHash {
	local filePath="$1"
	sha1sum "$filePath" | cut -d" " -f1
}

function nameToFilename {
	local name="$1"
	local now="$2"
	local forced="$3"

	local timestamp="$(($now / $cycle * $cycle))"
	local last="$(date +$format -d @$(($timestamp + ($cycle*-1)))).md"
	local current="$(date +$format -d @$(($timestamp + ($cycle*0)))).md"
	local next="$(date +$format -d @$(($timestamp + ($cycle*1)))).md"

	if [ "$1" == "last" ]; then
		echo "$last"
	elif [ "$1" == "current" ]; then
		echo "$current"
	elif [ "$1" == "next" ]; then
		echo "$next"
	else
		echo "$1.md"
	fi
}

# create file from template if it doesn't exist
# echos nothing if the file exists (important for removeUnused)
function createFileFromTemplate {
	local filePath="$1"
	# dont overwrite existing files
	if ! [ -f "$filePath" ]; then
		touch "$filePath"
		echo "# Tasks" >> "$filePath"
		cat "$template" >> "$filePath"
		echo "type ',task' to add more tasks" >> "$filePath"
		fileHash "$filePath"
	fi
}

function removeUnused {
	local filePath="$1"
	local templateHash="$2"
	local hashSum="$(fileHash "$filePath")"
	# if the file didn't exist and it wasn't modified, we remove it
	if [ -f "$filePath" ] && [ "$hashSum" != "" ] && [ "$hashSum" == "$templateHash" ]; then
		echo "Removing unmodified task file $filePath"
		rm "$filePath"
	fi
}

