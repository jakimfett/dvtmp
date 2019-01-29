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
	CREATE_CHAR="$TEST_CREATE_CHAR"
fi
if [ -z "$TEST_COPY1_CHAR" ]
then
	COPY1_CHAR="e" # Copy mode MOD e
else
	echo Using TEST_COPY1_CHAR
	COPY1_CHAR="$TEST_COPY1_CHAR"
fi
if [ -z "$TEST_FOCUS_NEXT_CHAR" ]
then
	FOCUS_NEXT_CHAR="j"
else
	echo Using TEST_FOCUS_NEXT_CHAR
	FOCUS_NEXT_CHAR="$TEST_FOCUS_NEXT_CHAR"
fi
if [ -z "$TEST_TAG_CHAR" ]
then
	TAG_CHAR="t"
else
	echo Using TEST_TAG_CHAR
	TAG_CHAR="$TEST_TAG_CHAR"
fi
if [ -z "$TEST_VIEW_CHAR" ]
then
	VIEW_CHAR="v"
else
	echo Using TEST_VIEW_CHAR
	VIEW_CHAR="$TEST_VIEW_CHAR"
fi
if [ -z "$TEST_PASTE_CHAR" ]
then
	PASTE_CHAR="p"
else
	echo Using TEST_PASTE_CHAR
	PASTE_CHAR="$TEST_PASTE_CHAR"
fi
ESC="" # \e
DVTMP="./dvtmp"
export DVTMP_EDITOR="vis"
LOG="dvtmp.log"
TEST_LOG="$0.log"
mkdir -p tests
resfn=./tests/resultsenvs.log
rm -f $resfn
UTF8_TEST_FN_ROOT="UTF-8-demo.txt"
UTF8_TEST_FN="./tests/$UTF8_TEST_FN_ROOT"
UTF8_TEST_URL="http://www.cl.cam.ac.uk/~mgk25/ucs/examples/$UTF8_TEST_FN_ROOT"

log_count=1
write_logs=0
if [ "$1" = "--debug" ] ; then
	keep_log=1
	shift 1
elif [ "$1" = "--debug_log" ] ; then
	keep_log=1
	export DEBUG_LOG_ROOT="$2"
	shift 2
else
	keep_log=0
fi
[ ! -z "$1" ] && DVTMP="$1"
export uppgm=$(echo $(basename $DVTMP) | tr "[a-z]" "[A-Z]")
set | grep -e $uppgm -e TEST_ -e _CHAR | sort >> $resfn


[ ! -x "$DVTMP" ] && echo "usage: [--debug] $0 path-to-dvtmp-binary [--setenv (env var base after pgm_ to set) value repeats if needed]" && exit 1


if [  "$1" = "--setenv" ]
then
	echo Setting vars for $uppgm
	while [ "$1" = "--setenv" ] ; do
		eval "export ${uppgm}_$2='$3'"
		shift 3
	done
fi

set | grep -e $uppgm -e TEST_ -e _CHAR | sort >> $resfn

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
	if [ -e "$afile" ]
	then
		sh_cmd "echo File $afile found!"
	else
		sh_cmd "echo Error file $afile not found!"
	fi
}

test_copymode1() { # requires wget, diff, vis
	local FILENAME=$UTF8_TEST_FN
	local COPY="$FILENAME.copy"
	[ ! -e "$FILENAME" ] && (wget "$UTF8_TEST_URL" -O "$FILENAME" > /dev/null 2>&1 || return 1)
	sleep 1
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY1_CHAR"
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
	local RESULT1=$?
	rm -f "$COPY"
	set | grep RESULT >> $resfn
	return $RESULT1
}

test_copymode2()
{ # requires wget, diff, vis
	local FILENAME="UTF-8-demo.txt"
	local COPY1="$FILENAME.copy2a"
	local COPY2="$FILENAME.copy2b"
	local COPY3="$FILENAME.copy2c"
	local COPY4="$FILENAME.copy2d"
	[ ! -e "$FILENAME" ] && (wget "$UTF8_TEST_URL" -O "$FILENAME" > /dev/null 2>&1 || return 1)
	sleep 1
	dvtmp_cmd "$CREATE_CHAR"
	dvtmp_cmd "$CREATE_CHAR"
	sh_cmd "echo Window 1"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY1_CHAR"
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
	dvtmp_cmd "$COPY1_CHAR"
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
	dvtmp_cmd "$COPY1_CHAR"
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
	dvtmp_cmd "$FOCUS_NEXT_CHAR"
	dvtmp_cmd "$COPY1_CHAR"
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
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	local RESULT2a=$(head "$COPY1" | grep "^Window" | wc -l)
	local RESULT2b=$(head "$COPY1" | grep "^Window 1" | wc -l)
	local RESULT2c=$(head "$COPY2" | grep "^Window" | wc -l)
	local RESULT2d=$(head "$COPY2" | grep "^Window 2" | wc -l)
	local RESULT2e=$(head "$COPY3" | grep "^Window" | wc -l)
	local RESULT2f=$(head "$COPY3" | grep "^Window 3" | wc -l)
	local RESULT2g=$(head "$COPY4" | grep "^Window" | wc -l)
	local RESULT2h=$(head "$COPY4" | grep "^Window 1" | wc -l)
	set | grep RESULT >> $resfn
	echo RESULT2a=RESULT2a >> $resfn
	echo RESULT2b=RESULT2b >> $resfn
	echo RESULT2c=RESULT2c >> $resfn
	echo RESULT2d=RESULT2d >> $resfn
	echo RESULT2e=RESULT2e >> $resfn
	echo RESULT2f=RESULT2f >> $resfn
	echo RESULT2g=RESULT2g >> $resfn
	echo RESULT2h=RESULT2h >> $resfn
	if [ $RESULT2a -eq 1 -a $RESULT2b -eq 1 -a \
	     $RESULT2c -eq 1 -a $RESULT2d -eq 1 -a \
	     $RESULT2e -eq 1 -a $RESULT2f -eq 1 -a \
	     $RESULT2g -eq 1 -a $RESULT2h -eq 1 ]
	then
		rm -f "$COPY1"
		rm -f "$COPY2"
		rm -f "$COPY3"
		return 0
	else
		echo "Copy mode 2 with windows failed."
		return 1
	fi
}

test_copymode3() { # requires wget, diff, vis
	local FILENAME="UTF-8-demo.txt"
	local COPY1="$FILENAME.copy3a"
	local COPY2="$FILENAME.copy3b"
	local COPY3="$FILENAME.copy3c"
	local COPY4="$FILENAME.copy3d"
	local COPY5="$FILENAME.copy3e"
	local COPY6="$FILENAME.copy3f"
	local COPY7="$FILENAME.copy3g"
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
	dvtmp_cmd "$COPY1_CHAR"
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
	dvtmp_cmd "$COPY1_CHAR"
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
	dvtmp_cmd "$COPY1_CHAR"
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
	dvtmp_cmd "$FOCUS_NEXT_CHAR"
	dvtmp_cmd "$COPY1_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY4"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY3"
	dvtmp_cmd "${VIEW_CHAR}2"
	sh_cmd "echo Window 4"
	sh_cmd "echo Tag 2"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY1_CHAR"
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
	dvtmp_cmd "$FOCUS_NEXT_CHAR"
	sh_cmd "echo Window 5"
	sh_cmd "echo Tag 2"
	sh_cmd "cat $FILENAME"
	dvtmp_cmd "$COPY1_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY6"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY6"
	dvtmp_cmd "$FOCUS_NEXT_CHAR"
	dvtmp_cmd "$COPY1_CHAR"
	dvtmp_input "1G"
	dvtmp_input '0'
	dvtmp_input 'vG1k$'
	dvtmp_input ":wq!\n"
	sleep 1
	sh_cmd "cat <<'EOF' > $COPY7"
	sleep 1
	dvtmp_cmd "$PASTE_CHAR"
	sh_cmd 'EOF'
	wait_4_file "$COPY7"
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	dvtmp_cmd "${VIEW_CHAR}1"
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	sh_cmd "exit"
	local RESULT3a=$(head "$COPY1" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT3b=$(head "$COPY1" | grep -e "^Tag 1" -e "^Window 1" | wc -l)
	local RESULT3c=$(head "$COPY2" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT3d=$(head "$COPY2" | grep -e "^Tag 1" -e "^Window 2" | wc -l)
	local RESULT3e=$(head "$COPY3" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT3f=$(head "$COPY3" | grep -e "^Tag 1" -e "^Window 3" | wc -l)
	local RESULT3g=$(head "$COPY4" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT3h=$(head "$COPY4" | grep -e "^Tag 1" -e "^Window 1" | wc -l)
	local RESULT3i=$(head "$COPY5" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT3j=$(head "$COPY5" | grep -e "^Tag 2" -e "^Window 4" | wc -l)
	local RESULT3k=$(head "$COPY6" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT3l=$(head "$COPY6" | grep -e "^Tag 2" -e "^Window 5" | wc -l)
	local RESULT3m=$(head "$COPY7" | grep -e "^Tag" -e "^Window" | wc -l)
	local RESULT3n=$(head "$COPY7" | grep -e "^Tag 1" -e "^Window 1" | wc -l)
	set | grep RESULT >> $resfn
	if [ $keep_log -eq 0 -a $RESULT3a -eq 1 -a $RESULT3b -eq 1 -a \
	     $RESULT3b -eq 1 -a $RESULT3c -eq 1 -a \
	     $RESULT3d -eq 1 -a $RESULT3e -eq 1 -a \
	     $RESULT3f -eq 1 -a $RESULT3g -eq 1 -a \
	     $RESULT3h -eq 1 -a $RESULT3i -eq 1 -a \
	     $RESULT3j -eq 1 -a $RESULT3k -eq 1 -a \
	     $RESULT3l -eq 1 -a $RESULT3m -eq 1 -a \
	     $RESULT3n -eq 1  ]
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
	if [ $write_logs -eq 1 ]
	then
		export DVTM_LOGNAME="$DEBUG_LOG_ROOT$log_count"
		(( log_count = log_count + 1 ))
	fi
	$DVTMP -v 1>&2
	if [ $write_logs -eq 1 ]
	then
		export DVTM_LOGNAME="$DEBUG_LOG_ROOT$log_count"
		(( log_count = log_count + 1 ))
	fi
	test_copymode1 && echo "copymode1: OK" 1>&2 || echo "copymode1: FAIL" 1>&2;
} 2> "$TEST_LOG" | $DVTMP -m ^g 2> $LOG

cat "$TEST_LOG"

{
	echo "Testing copymode2 for $DVTMP" 1>&2
	if [ $write_logs -eq 1 ]
	then
		export DVTM_LOGNAME="$DEBUG_LOG_ROOT$log_count"
		(( log_count = log_count + 1 ))
	fi
	test_copymode2 && echo "copymode2: OK" 1>&2 || echo "copymode2: FAIL" 1>&2;
} 2> "$TEST_LOG" | $DVTMP -m ^g 2> $LOG

cat "$TEST_LOG"

{
	echo "Testing copymode3 for $DVTMP" 1>&2
	if [ $write_logs -eq 1 ]
	then
		export DVTM_LOGNAME="$DEBUG_LOG_ROOT$log_count"
		(( log_count = log_count + 1 ))
	fi
	$DVTMP -v 1>&2
	test_copymode3 && echo "copymode3: OK" 1>&2 || echo "copymode3: FAIL" 1>&2;
} 2> "$TEST_LOG" | $DVTMP -m ^g 2> $LOG

cat "$TEST_LOG"

if [ $? -eq 0 -a $keep_log -eq 0 ] ; then
	rm "$TEST_LOG" $LOG
	rm $UTF8_TEST_FN
fi
