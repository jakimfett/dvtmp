#!/bin/sh
#set -n

if [ -z "$TEST_MOD_CHAR" ]
then
	MOD_CHAR="" # CTRL+g
else
	echo Using TEST_MOD_CHAR
	MOD_CHAR="$TEST_MOD_CHAR"
fi
if [ -z "$TEST_CREATE_CHAR" ]
then
	CREATE_CHAR="c" # Create window using MOD c
else
	echo Using TEST_CREATE_CHAR
	CREATE_CHAR="$TEST_CREATE"
fi
if [ -z "$TEST_COPY_CHAR" ]
then
	COPY_CHAR="e" # Copy mode MOD e
else
	echo Using TEST_COPY_CHAR
	COPY_CHAR="$TEST_COPY_CHAR"
fi
if [ -z "$TEST_FOCUS_NEXT" ]
then
	FOCUS_NEXT_CHAR="j"
else
	echo Using TEST_FOCUS_NEXT
	FOCUS_NEXT_CHAR="$TEST_FOCUS_NEXT"
fi
if [ -z "$TEST_TAG" ]
then
	TAG_CHAR="t"
else
	echo Using TEST_TAG
	TAG_CHAR="$TEST_TAG"
fi
if [ -z "$TEST_VIEW" ]
then
	VIEW_CHAR="v"
else
	echo Using TEST_VIEW
	VIEW_CHAR="$TEST_VIEW"
fi
if [ -z "$TEST_PASTE" ]
then
	PASTE_CHAR="p"
else
	echo Using TEST_PASTE
	PASTE_CHAR="$TEST_PASTE"
fi
ESC="" # \e
DVTMP="./dvtmp"
export DVTMP_EDITOR="vis"
LOG="dvtmp.log"
TEST_LOG="$0.log"
mkdir -p tests
UTF8_TEST_FN_ROOT="UTF-8-demo.txt"
UTF8_TEST_FN="./tests/$UTF8_TEST_FN_ROOT"
UTF8_TEST_URL="http://www.cl.cam.ac.uk/~mgk25/ucs/examples/$UTF8_TEST_FN_ROOT"

if [ "$1" = "--debug" ] ; then
	keep_log=1
	shift 1
else
	keep_log=0
fi
[ ! -z "$1" ] && DVTMP="$1"
[ ! -x "$DVTMP" ] && echo "usage: [--debug] $0 path-to-dvtmp-binary" && exit 1

dvtmp_input() {
	printf "$1"
}

dvtmp_cmd() {
	printf "${MOD_CHAR}$1"
	sleep 1
}

sh_cmd() {
	printf "$1\n"
	sleep 1
}

wait_4_file()
{
	afile="$1"
	ic=0
	sh_cmd "echo checking for $afile"
	while [ $ic -lt 10 -a ! -r "$afile" ]; do
		sleep 1
		(( ic = ic + 1 ))
	done
	if [ ! -f "$afile" ]
	then
		sh_cmd "echo Error file $afile not found!"
	fi
}

test_copymode1() { # requires wget, diff, vis
	local FILENAME=$UTF8_TEST_FN
	local COPY="$FILENAME.copy"
	[ ! -e "$FILENAME" ] && (wget "$UTF8_TEST_URL" -O "$FILENAME" > /dev/null 2>&1 || return 1)
	sleep 1
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY_CHAR"
	dvtmp_input "?UTF-8 encoded\n"
	dvtmp_input '^kvG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY"
	#dvtmp_input "exit\n"
	sh_cmd "exit"
	sh_cmd "exit"
	diff -u "$FILENAME" "$COPY" 1>&2
	local RESULT=$?
	rm -f "$COPY"
	return $RESULT
}

test_copymode2() { # requires wget, diff, vis
	local FILENAME="UTF-8-demo.txt"
	local COPY1="$FILENAME.copy2a"
	local COPY2="$FILENAME.copy2b"
	local COPY3="$FILENAME.copy2c"
	[ ! -e "$FILENAME" ] && (wget "$UTF8_TEST_URL" -O "$FILENAME" > /dev/null 2>&1 || return 1)
	sleep 1
	dvtmp_cmd "$CREATE_CHAR"
	dvtmp_cmd "$CREATE_CHAR"
	sh_cmd "echo Window 1"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY1"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY1"
	dvtmp_cmd "$FOCUS_NEXT_CHAR"
	sh_cmd "echo Window 2"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY2"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY2"
	dvtmp_cmd "$FOCUS_NEXT_CHAR"
	sh_cmd "echo Window 3"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY3"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY3"
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	local RESULT1a=$(head "$COPY1" | grep "^Window" | wc -l)
	local RESULT1b=$(head "$COPY1" | grep "^Window 1" | wc -l)
	local RESULT2a=$(head "$COPY2" | grep "^Window" | wc -l)
	local RESULT2b=$(head "$COPY2" | grep "^Window 2" | wc -l)
	local RESULT3a=$(head "$COPY3" | grep "^Window" | wc -l)
	local RESULT3b=$(head "$COPY3" | grep "^Window 3" | wc -l)
	if [ $RESULT1a -eq 1 -a $RESULT1b -eq 1 -a \
	     $RESULT2a -eq 1 -a $RESULT2b -eq 1 -a \
	     $RESULT3a -eq 1 -a $RESULT3b -eq 1 ]
	then
		rm -f "$COPY1"
		rm -f "$COPY2"
		rm -f "$COPY3"
		return 0
	else
		echo "Copy mode 2 with windows failed."
		return $(( $RESULT1a + $RESULT1b + $RESULT2a + $RESULT2b ))
	fi
} 

test_copymode3() { # requires wget, diff, vis
	local FILENAME="UTF-8-demo.txt"
	local COPY1="$FILENAME.copy3a"
	local COPY2="$FILENAME.copy3b"
	local COPY3="$FILENAME.copy3c"
	local COPY4="$FILENAME.copy3d"
	local COPY5="$FILENAME.copy3e"
	[ ! -e "$FILENAME" ] && (wget "$UTF8_TEST_URL" -O "$FILENAME" > /dev/null 2>&1 || return 1)
	sleep 1
	dvtmp_cmd "$CREATE_CHAR"
	dvtmp_cmd "$CREATE_CHAR"
	dvtmp_cmd "$CREATE_CHAR"
	dvtmp_cmd "4"
	dvtmp_cmd "${TAG_CHAR}2"
	dvtmp_cmd "$CREATE_CHAR"
	dvtmp_cmd "4"
	dvtmp_cmd "${TAG_CHAR}2"
	dvtmp_cmd "1"
	sh_cmd "echo Window 1"
	sh_cmd "echo Tag 1"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY1"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY1"
	dvtmp_cmd "$FOCUS_NEXT_CHAR"
	sh_cmd "echo Window 2"
	sh_cmd "echo Tag 1"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY2"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY2"
	dvtmp_cmd "$FOCUS_NEXT_CHAR"
	sh_cmd "echo Window 3"
	sh_cmd "echo Tag 1"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY3"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY3"
	dvtmp_cmd "${VIEW_CHAR}2"
	sh_cmd "echo Window 4"
	sh_cmd "echo Tag 2"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY4"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY4"
	dvtmp_cmd "$FOCUS_NEXT_CHAR"
	sh_cmd "echo Window 5"
	sh_cmd "echo Tag 2"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY5"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY5"
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	dvtmp_cmd "${VIEW_CHAR}1"
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	local RESULT1a=$(head "$COPY1" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT1b=$(head "$COPY1" | grep -e "^Tag 1" -e "^Window 1" | wc -l)
	local RESULT2a=$(head "$COPY2" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT2b=$(head "$COPY2" | grep -e "^Tag 1" -e "^Window 2" | wc -l)
	local RESULT3a=$(head "$COPY3" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT3b=$(head "$COPY3" | grep -e "^Tag 1" -e "^Window 3" | wc -l)
	local RESULT4a=$(head "$COPY4" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT4b=$(head "$COPY4" | grep -e "^Tag 2" -e "^Window 4" | wc -l)
	local RESULT5a=$(head "$COPY5" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT5b=$(head "$COPY5" | grep -e "^Tag 2" -e "^Window 5" | wc -l)
	if [ $RESULT1a -eq 1 -a $RESULT1b -eq 1 -a \
	     $RESULT2a -eq 1 -a $RESULT2b -eq 1 -a \
	     $RESULT3a -eq 1 -a $RESULT3b -eq 1 ]
	then
		rm -f "$COPY1"
		rm -f "$COPY2"
		rm -f "$COPY3"
		return 0
	else
		echo "Copy mode 2 with windows failed."
		return $(( $RESULT1a + $RESULT1b + $RESULT2a + $RESULT2b ))
	fi
} 

if ! which vis > /dev/null 2>&1 ; then
	echo "vis not found, skiping copymode test"
	exit 0
fi

{
	echo "Testing copymode1 for $DVTMP" 1>&2
	$DVTMP -v 1>&2
	test_copymode1 && echo "copymode1: OK" 1>&2 || echo "copymode1: FAIL" 1>&2;
} 2> "$TEST_LOG" | $DVTMP -m ^g 2> $LOG

cat "$TEST_LOG"

{
	echo "Testing copymode2 for $DVTMP" 1>&2
	$DVTMP -v 1>&2
	test_copymode2 && echo "copymode2: OK" 1>&2 || echo "copymode2: FAIL" 1>&2;
} 2> "$TEST_LOG" | $DVTMP -m ^g 2> $LOG

cat "$TEST_LOG"

{
	echo "Testing copymode3 for $DVTMP" 1>&2
	$DVTMP -v 1>&2
	test_copymode3 && echo "copymode3: OK" 1>&2 || echo "copymode3: FAIL" 1>&2;
} 2> "$TEST_LOG" | $DVTMP -m ^g 2> $LOG

cat "$TEST_LOG"

if [ $? -eq 0 -a $keep_log -eq 0 ] ; then
	rm "$TEST_LOG" $LOG
fi
rm $UTF8_TEST_FN
