#!/bin/sh
#set -n

MOD="" # CTRL+g
ESC="" # \e
DVTM_CONFIG="./dvtm-config"
export DVTM_CONFIG_EDITOR="vis"
LOG="dvtm-config.log"
TEST_LOG="$0.log"
UTF8_TEST_FN="UTF-8-demo.txt"
UTF8_TEST_URL="http://www.cl.cam.ac.uk/~mgk25/ucs/examples/$UTF8_TEST_FN"

if [ "$1" = "--debug" ] ; then
	keep_log=1
	shift 1
else
	keep_log=0
fi
[ ! -z "$1" ] && DVTM_CONFIG="$1"
[ ! -x "$DVTM_CONFIG" ] && echo "usage: [--debug] $0 path-to-dvtm-config-binary" && exit 1

dvtm_config_input() {
	printf "$1"
}

dvtm_config_cmd() {
	printf "${MOD}$1"
	sleep 2
}

sh_cmd() {
	printf "$1\n"
	sleep 2
}

test_copymode() { # requires wget, diff, vis
	dvtm_config_cmd 'c'
	dvtm_config_cmd 'c'
	dvtm_config_cmd 'c'
	dvtm_config_cmd '1'
	local FILENAME="UTF-8-demo.txt"
	local COPY="$FILENAME.copy"
	[ ! -e "$FILENAME" ] && (wget "$UTF8_TEST_URL" -O "$FILENAME" > /dev/null 2>&1 || return 1)
	sleep 1
	sh_cmd "cat $FILENAME"
	dvtm_config_cmd 'e'
	sleep 2
	dvtm_config_input "?UTF-8 encoded\n"
	#Split up input to stop it from getting caught in edit mode.
	dvtm_config_input '^'
	dvtm_config_input 'k'
	dvtm_config_input 'vG'
	dvtm_config_input '1k$'
	dvtm_config_input ":"
	dvtm_config_input "wq!\n"
	sleep 2
	dvtm_config_cmd '2'
	sh_cmd "cat <<'EOF' > $COPY"
	while [ ! -r "$COPY" ]; do sleep 1; done;
	dvtm_config_input "exit\n"
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
	echo "Testing $DVTM_CONFIG" 1>&2
	$DVTM_CONFIG -v 1>&2
	test_copymode && echo "copymode: OK" 1>&2 || echo "copymode: FAIL" 1>&2;
} 2> "$TEST_LOG" | $DVTM_CONFIG -m ^g 2> $LOG

cat "$TEST_LOG"
if [ $? -eq 0 -a $keep_log -eq 0 ] ; then
	rm "$TEST_LOG" $LOG
fi
rm $UTF8_TEST_FN
