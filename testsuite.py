#!/usr/bin/env python2

import os
import pexpect

MDEF_MOD = "^G"
MPGM = "./dvtm-config"
MESC = '^['
os.environ["DVTM_CONFIG"] = pgm
MEDITOR  = "vis"
os.environ["DVTM_CONFIG_EDITOR"] = meditor
MLOG ="dvtm-config.log"
MTEST_LOG = "$0.log"
MUTF8_TEST_FN = "UTF-8-demo.txt"
MUTF8_TEST_URL = "http://www.cl.cam.ac.uk/~mgk25/ucs/examples/" + UTF8_TEST_FN

test_copy(filename, mod_char, cmd):
    child = pexpect.spawn(cmd)
    child.expect('$', timeout=120)
    child.sendline("cat " + filename)
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
child.expect ('prompt# ')
#child.maxread=100000
	[ ! -e "$FILENAME" ] && (wget "$UTF8_TEST_URL" -O "$FILENAME" > /dev/null 2>&1 || return 1)
	sleep 1
test_copy( MUTF8_TEST_FN, MDEF_MOD, MPGM + " 'sh'")
