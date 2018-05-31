#!/usr/bin/env sh

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

