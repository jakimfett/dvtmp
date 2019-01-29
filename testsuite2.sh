#!/bin/sh
#set -n

#Test with different create character.
export DVTMP_CREATE="+"
export TEST_CREATE_CHAR=$DVTMP_CREATE
export DVTMP_MASTER_DECR="<"
export DVTMP_MASTER_INCR=">"
export DVTMP_COPY_MODE1="*"
export TEST_COPY1_CHAR=$DVTMP_COPY_MODE1
export DVTMP_PASTE="."
export TEST_PASTE_CHAR=$DVTMP_PASTE
export DVTMP_FOCUS_NEXT="l"
export TEST_FOCUS_NEXT_CHAR=$DVTMP_FOCUS_NEXT

./testsuite.sh $*
