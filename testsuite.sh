#!/bin/sh
#set -n

MOD="" # CTRL+g
ESC="" # \e
DVTM_PLUS="./dvtm-plus"
export DVTM_PLUS_EDITOR="vis"
LOG="dvtm-plus.log"
TEST_LOG="$0.log"
UTF8_TEST_FN="UTF-8-demo.txt"
UTF8_TEST_URL="http://www.cl.cam.ac.uk/~mgk25/ucs/examples/$UTF8_TEST_FN"

if [ "$1" = "--debug" ] ; then
	keep_log=1
	shift 1
else
	keep_log=0
fi
[ ! -z "$1" ] && DVTM_PLUS="$1"
[ ! -x "$DVTM_PLUS" ] && echo "usage: [--debug] $0 path-to-dvtm-plus-binary" && exit 1

dvtm_plus_input() {
	printf "$1"
}

dvtm_plus_cmd() {
	printf "${MOD}$1"
	sleep 2
}

sh_cmd() {
	printf "$1\n"
	sleep 2
}

test_copymode() { # requires wget, diff, vis
	local COPY="$UTF8_TEST_FN.copy"
	sh_cmd 'echo PID=$$'
	sh_cmd "cat $UTF8_TEST_FN"
	[ ! -e "$UTF8_TEST_FN" ] && (wget "$UTF8_TEST_URL" -O "$UTF8_TEST_FN" > /dev/null 2>&1 || return 1)
	sh_cmd "cat $UTF8_TEST_FN"
	dvtm_plus_cmd 'e'
	sleep 2
	dvtm_plus_input "?UTF-8 encoded\n"
	#Split up input to stop it from getting caught in edit mode.
	dvtm_plus_input '^'
	dvtm_plus_input 'k'
	dvtm_plus_input 'vG'
	dvtm_plus_input '1k$'
	dvtm_plus_input ":"
	dvtm_plus_input "wq!\n"
	sleep 2
	sh_cmd "cat <<'EOF' > $COPY"
	dvtm_plus_cmd 'p'
	sh_cmd 'EOF'
	while [ ! -r "$COPY" ]; do sleep 1; done;
	dvtm_plus_input "exit\n"
	diff -u "$FILENAME" "$COPY" 1>&2
	local RESULT=$?
	rm -f "$COPY"
	return $RESULT
}

if ! which vis > /dev/null 2>&1 ; then
	echo "vis not found, skiping copymode test"
	exit 0
fi

{
	echo "Testing $DVTM_PLUS" 1>&2
	$DVTM_PLUS -v 1>&2
	test_copymode && echo "copymode: OK" 1>&2 || echo "copymode: FAIL" 1>&2;
} 2> "$TEST_LOG" | $DVTM_PLUS -m ^g 2> $LOG

cat "$TEST_LOG"
if [ $? -eq 0 -a $keep_log -eq 0 ] ; then
	rm "$TEST_LOG" $LOG
fi
rm $UTF8_TEST_FN
