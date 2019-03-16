#!/bin/bash

################
# Batch Submit #
################

# This project is a functional proof-of-concept Bash script designed to allow multiple processes
# to be run sequentially in the background on Linux. It is designed so that multiple scripts for
# programs such as R or Stata can be run in the background without interfering with each other
# or requiring manual intervention. Output from scripts will be written to a file created by mktemp
# in the same directory as the submitted script.
#
# © The Regents of the University of California, Davis campus, 2019. All rights reserved.

error() {
	echo "Try '$0' for more information."
	exit 1
}

usage() {
	echo "usage: $0 -p PROGRAM -f file"
	echo "       $0 -p PROGRAM -f file1 -f file2 ... "
	echo "       $0 -p PROGRAM [-a ARGS] -f file1 -f file2 ... "
	exit 1
}

if [ $# -eq 0 ]; then
	usage
fi

while getopts ":p:a:f:" OPT; do
	case "$OPT" in
		p)
			PROGRAM="$OPTARG"
			;;
		a)
			ARGS="$OPTARG"
			;;
		f)
			FILES+=("$OPTARG")
			;;
		\?)
			echo "$0: invalid option -- '$OPTARG'"
			error
			;;
		:)
			echo "$0: '$OPTARG' requires an argument"
			error
			;;
	esac
done
shift "$((OPTIND-1))"

if [ -z "$PROGRAM" ]; then
	echo "$0: you must specify a program"
	error
elif ! command -v "$PROGRAM" > /dev/null 2>&1; then
	echo "$0: program '$PROGRAM' not found"
	error
fi

if [ ${#FILES[@]} -eq 0 ]; then
	echo "$0: no files submitted"
	error
fi

for FILE in "${FILES[@]}"; do
	INFILE="$(readlink -mnqs "$FILE")"
	OUTFILE="$(mktemp -q "$INFILE".out.XXX)"

	CMD=("$PROGRAM")
	if [ ! -z "$ARGS" ]; then
		CMD+=("$ARGS")
	fi
	CMD+=("<")
	CMD+=(\""$INFILE"\")
	CMD+=(">")
	CMD+=(\""$OUTFILE"\")
	CMD+=("2>&1")
	CMD+=("&")

	eval "${CMD[@]}"
	PID="$!"

	while kill -0 "$PID" > /dev/null 2>&1; do
		sleep 60
	done
done
