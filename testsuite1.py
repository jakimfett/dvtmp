#!/usr/bin/env python
import os
import pexpect
import subprocess
import sys
import time

mod = "\0007" # CTRL+g
esc = "" # \e
dvtmp = "./dvtmp"
os.environ["DVTMP_EDITOR"] = "vis"
log = "dvtmp.log"
test_log = sys.argv[0] + ".log"
utf8_test_fn = "UTF-8-demo.txt"
copy = utf8_test_fn + ".copy"
utf8_test_url = "http://www.cl.cam.ac.uk/~mgk25/ucs/examples/" + utf8_test_fn
keep_log = 1
trace_log = 0
mfp = open(test_log, "w")
tres = 0

def logit(msg):
    global mfp
    if mfp is not None:
        mfp.write("{0}\n".format(msg))

def prlog(msg):
    print("{0}\n".format(msg))
    logit(msg)

def tr_ps():
    global mfp
    res = subprocess.call("ps -ef | grep %s 2>&1 > ps.log" % (os.environ["USER"]), shell=True)
    res = subprocess.call("cat ps.log", shell=True)
    if mfp is not None:
        mfp.close()
        res = subprocess.call("cat ps.log >> %s" % (trace_log), shell=True)
        mfp = open(test_log, "w")

def sh_cmd(cmd):
    prlog("Sending " + cmd)
    child.sendline(cmd)
    time.sleep(2)
    logit(child.before)
    logit(child.after)
    tr_ps()

def dvtmp_input(cmd):
    prlog("Sending without added line feed." + cmd)
    child.send(cmd)
    time.sleep(2)
    logit(child.before)
    logit(child.after)
    tr_ps()

def dvtmp_cmd(cmd):
    prlog("Sending with mod character." + cmd)
    child.send(mod)
    time.sleep(1)
    child.send(cmd)
    time.sleep(2)
    logit(child.before)
    logit(child.after)
    tr_ps()

def cat_st_edit():
    sh_cmd("cat " + utf8_test_fn)
    dvtmp_cmd("e")

def check_copy_mode():
    prlog("Check for vis editor to do copy test.")
    res = subprocess.call("/usr/bin/which vis", shell=True)
    if res != 0:
        prlog("No vis. Skipping copy mode test.")
        return res

    if (not os.path.isfile(utf8_test_fn)):
        res = subprocess.call("wget '%s' -O '%s' 2>&1 -o wget1.log > wget2.log" % (utf8_test_url, utf8_test_fn), shell=True)
        if (res != 0) or (not os.path.isfile(utf8_test_fn)):
            prlog("No %s downloaded. Skipping copy mode test." % (utf8_test_url))
            return 1

    child = pexpect.spawn(dvtmp)
    res = child.expect("\$", timeout=30)
    logit(child.before)
    logit(child.after)
    cat_st_edit()
    dvtmp_input(":q!")
    sh_cmd("echo first after editing %s without changes." % (copy))
    res = child.expect("\$", timeout=30)

    cat_st_edit()
    dvtmp_input("?")
    dvtmp_input("UTF-8 encoded\n")
    dvtmp_input("^")
    dvtmp_input("k")
    dvtmp_input("vG")
    dvtmp_input("1k")
    dvtmp_input("$")
    dvtmp_input(":")
    dvtmp_input("wq!\n")
    sh_cmd("echo after editing %s with changes." % (copy))
    res = child.expect("\$", timeout=30)
    sh_cmd("echo 'successfully out of editing'" + copy)
    res = child.expect("\$", timeout=30)
    sh_cmd("cat <<'EOF' > " + copy)
    dvtmp_cmd("p")
    sh_cmd("EOF")
    if (not os.path.isfile(copy)):
        time.sleep(1)
    res = child.expect("\$", timeout=30)
    child.sendline("exit")
    res = child.expect(pexpect.EOF)
    prlog("Copy mode successful.")

ic = 1
while (ic < len(sys.argv) > 1) and (sys.argv[ic] == "--debug"):
	if (sys.argv[ic] == "--debug"):
		keep_log = 1
        elif (sys.argv[ic] == "--trace"):
		trace_log = 1
        else:
            dvtmp = sys.argv[ic]
            if not os.access(dvtmp, os.X_OK):
                dvtmp = sys.argv[ic]
                print("usage: [--debug] [--trace_log] $0 path-to-dvtmp-binary")
                exit(1)
        ic = ic + 1

prlog("Testing version of %s" % (dvtmp))
child = pexpect.spawn(dvtmp + " -v")
res = child.expect(pexpect.EOF)
logit(child.before)
logit(child.after)
prlog("Successful.")

prlog("Testing exit command from shell.")
child = pexpect.spawn(dvtmp)
prompt = child.expect("\$", timeout=30)
logit(child.before)
logit(child.after)
child.sendline("exit")
res = child.expect(pexpect.EOF)
prlog("Shell successful.")

res = check_copy_mode()
if (res != 0):
    tres = res

#Close log file.
mfp.close()
mfp = None

if (tres == 0) and (keep_log == 0):
    prlog("Removing test and log files.")
    os.remove(utf8_test_fn)
    os.remove(copy)
    os.remove(test_log)
    os.remove("wget1.log")
    os.remove("wget2.log")
else:
    prlog("Log file is %s." % (test_log))
