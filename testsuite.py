#!/usr/bin/env python2

import os
import sys
import time
from os.path import join, isdir, isfile, dirname
import pexpect

MDEF_MOD = "^G"
MPGM = "./dvtm-plus"
MESC = '^['
os.environ["DVTM_PLUS"] = MPGM
MTEST_PS1='test-prompt:'
MEDITOR  = "vis"
os.environ["DVTM_PLUS_EDITOR"] = MEDITOR
MLOG ="dvtm-plus.log"
MSHELL = "bash"
MDVTM_TEST_CMD = "%s '%s --init-file ./test-bashrc'" % (MPGM, MSHELL)
MTEST_LOG = "$0.log"
MUTF8_TEST_FN = "UTF-8-demo.txt"
MUTF8_TEST_FN_COPY = "UTF-8-demo.txt.copy"
MUTF8_TEST_URL = "http://www.cl.cam.ac.uk/~mgk25/ucs/examples/" + MUTF8_TEST_FN

def dvtm_config_cmd(logfn, child, mod_char, cmd):
    logfn.write("Sending %%\n" % (mod_char,cmd))
    child.send(mod_char + cmd)
    time.sleep(2)
    
def dvtm_config_input(child, cmd):
    child.send(cmd)
    time.sleep(2)
    
def test_copy(filename, logfile, mod_char, cmd):
    logfn = open(logfile, 'w')
    sys.stdout = os.fdopen (sys.stdout.fileno(), 'w', 0)
    os.dup2 (logfn.fileno(), sys.stdout.fileno());

    print("Spawning " + cmd)
    child = popen_pexpect.spawn(cmd)
    time.sleep(1)
    logfn.write("Spawning " + cmd + "\n")
    child.expect([MTEST_PS1, pexpect.EOF], timeout=120)
    child.sendline("cat " + filename)
    child.expect([MTEST_PS1, pexpect.EOF], timeout=120)
    dvtm_config_cmd(child, mod_char, 'e')
    time.sleep(3)
    dvtm_config_input(child, "?UTF-8 encoded\n")
    #Split up input to stop it from getting caught in edit mode.
    dvtm_config_input(child, '^')
    dvtm_config_input(child, 'k')
    dvtm_config_input(child, 'vG')
    dvtm_config_input(child, '1k$')
    dvtm_config_input(child, ':')
    time.sleep(2)
    dvtm_config_input(child, 'wq!\n')
    time.sleep(2)
    child.sendline("cat <<'EOF' > " + MUTF8_TEST_FN_COPY)
#child.maxread=100000
    dvtm_config_cmd(child, mod_char, "p")
    time.sleep(2)
    child.sendline("'EOF'")
    time.sleep(2)
    dvtm_config_cmd(child, mod_char, "q")
    child.send("q")
    child.close()
    logfn.close()

if (not isfile(MUTF8_TEST_FN)):
    rtn = os.system("wget %s -O %s > /dev/null 2>&1" % (MUTF8_TEST_URL, MUTF8_TEST_FN))
    if (rtn != 0):
        exit(1)
    if (not isfile(MUTF8_TEST_FN)):
        exit(1)
time.sleep(2)

test_copy(MUTF8_TEST_FN, "test-mod-def.log", MDEF_MOD, MDVTM_TEST_CMD)
