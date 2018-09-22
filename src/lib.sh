#!/usr/bin/env bash

function usage {
	local cmd="$1"
	local action="$2"

	echo -e "Task File '$action' does not exist.\n"
	echo -e "Usage: $cmd [operation] [options]"
	echo -e "Operations:"
	echo -e "\topen\tLists tasks which are undone and due"
	echo -e ""
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
	echo -e "\t-a\t can be used with the 'open' operation to show all tasks (e.g. future tasks too)"
	echo -e ""
	echo -e "For all operations which are not the 'current' one, the 'current' operation will be displayed next to it."
}

function setup {
	local pkgdatadir="$1"
	local sysconfig="$2"
	local userconfig="$3"

	# load system default
	local directory="$(loadConfigValueEvaluated "directory" "$XDG_DATA_HOME/witfocus" "$sysconfig" "$userconfig")"

	echo "It looks like you are running witfocus for the first time. Starting setup:"
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
		return 1
	fi

	grep -e "^$field:" "$file" \
		| cut -d':' -f2- \
		| sed 's/\(^[[:space:]]\+\|[[:space:]]\+$\)//g'
}

function colonValueExists {
	local field=$1
	local file=$2

	if ! [ -f "$file" ]; then
		return 1
	fi

	if grep -e "^$field:" "$file" >/dev/null; then
		return 0
	fi
	return 1
}

function loadConfigValue {
	local field="$1"
	local defaultValue="$2"
	local systemConfig="$3"
	local userConfig="$4"

	# read from userconfig
	if colonValueExists "$field" "$userConfig"; then
		colonValue "$field" "$userConfig"
	elif colonValueExists "$field" "$systemConfig"; then
		colonValue "$field" "$systemConfig"
	else
		echo "$defaultValue"
	fi
}

function loadConfigValueEvaluated {
	local value="$(loadConfigValue "$@")"
	eval "echo $value" # to evaluate variables like: $XDG_DATA_HOME
}

function fileHash {
	local filePath="$1"
	sha1sum "$filePath" | cut -d" " -f1
}

function cycleCalculator {
	local i=0
	local timestamp="$1"
	local cycleSize="$2"
	local factor="$3"
	local blacklist="$4"
	local blacklistFormat="$5"
	local target="$(date +%s -d @$(($timestamp + ($cycleSize*$factor) )) )"

	# check the blacklist
	for i in {0..1000}; do # max 1000 cycles
		if [ "$blacklist" != "" ] && [ "$blacklistFormat" != "" ] && \
			[ $(listContains "$blacklist" "$(date +$blacklistFormat -d @$target)") == "true" ]; then
			if [ $factor -lt 0 ]; then
				target="$(($target-$cycleSize))"
			else
				target="$(($target+$cycleSize))"
			fi
		else
			break
		fi
		if [ "$i" == "1000" ]; then
			echo "Blacklist exhausted, you probably want to reconfigure it." > /dev/stderr
			sleep 10
		fi
	done

	echo "$target"
}

function listContains {
	list="$1"
	needle="$2"
	for x in $list; do
		if [ "$needle" == "$x" ]; then
			echo "true"
			return
		fi
	done
	echo "false"
}

function nameToFilename {
	local name="$1"
	local now="$2"
	local forced="$3"
	local blacklist="$4"
	local blacklistFormat="$5"

	local target="$name"
	# NOTE: using a multiple of the cycle as timestamp causes problems with
	# timezones as the result is the start of the cycle in UTC and not the
	# local time, therefore it was removed again
	local timestamp="$now"

	if [ "$name" == "last" ] || [ "$name" == "current" ] || [ "$name" == "next" ]; then
		local factor=0
		if [ "$name" == "last" ]; then
			factor=-1
		elif [ "$name" == "next" ]; then
			factor=1
		fi

		# use the blacklist for the calculation
		local targetDate="$(cycleCalculator "$timestamp" "$cycle" "$factor" "$blacklist" "$blacklistFormat")"
		local target="$(date +$format -d @$targetDate)"
	fi

	echo "$target.md"
}

# create file from template if it doesn't exist
# echos hash of new file, if new file is created
# echos nothing if the file exists (important for removeUnused)
function createFileFromTemplate {
	local filePath="$1"
	local cycle="$2"
	local instructions="$3"
	local newFileTemplate="$4"
	local taskTemplate="$5"
	local fullTaskTemplate="$6"

	# dont overwrite existing files
	if ! [ -f "$filePath" ]; then
		# replace placeholders
		# FIXME: Process substitution (<()) is not POSIX compatible
		local out="$(cat "$newFileTemplate")"
		out="$(awk 'NR==FNR{rep=(NR>1?rep RS:"") $0; next} {gsub(/{TASK}/,rep)}1' "$taskTemplate" <(echo "$out"))"
		out="$(awk 'NR==FNR{rep=(NR>1?rep RS:"") $0; next} {gsub(/{FULLTASK}/,rep)}1' "$fullTaskTemplate" <(echo "$out"))"
		echo "$out" | sed \
			-e "s/{CYCLE}/$cycle/g" \
			-e "s/{INSTRUCTIONS}/$instructions/g" \
			>> "$filePath"
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

function openAction {
	local directory="$1"
	local matchRegex="$2"

	nonFutureContent "$directory" "$matchRegex" | sed -e 's;^[^:]*/;;' -e 's/.md:-/:/' | sort -s -k 1,1
}

function nonFutureContent {
	local directory="$1"
	# if the date check should be skipped the regex is empty
	local matchRegex="$2"
	local filenamePart

	for f in "$directory"/*.md; do
		# echo "checking $f" >/dev/stderr
		if [ -f "$f" ]; then
			# echo "$f is a regular file" >/dev/stderr
			filenamePart="$(basename "$f" | sed "s/\.md$//")"
			matchCount="$(echo "$filenamePart" | grep -cP "^$matchRegex$" || true)"
			if [ "$matchCount" == "1" ]; then
				# echo "$f is a file with a date format name" >/dev/stderr
				if date -d "$filenamePart">/dev/null 2>&1; then
					# echo "$filenamePart is actually a valid date" >/dev/stderr
					local timestamp="$(date -d "$filenamePart" +%s)"
					local now="$(date +%s)"
					if [ "$timestamp" -gt "$now" ]; then
						# echo "$f is a file with a future date, skip it" >/dev/stderr
						continue
					fi
				fi
			fi
			# we use grep here instead of cat as we require the filename at the beginning of each line
			grep -Hri "\- \[ \]" "$f" || true
		fi
	done
}
