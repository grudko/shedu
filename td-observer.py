#!/usr/bin/env python

import os
import sys
import errno
import time
import socket
import json
import Queue
import threading
from subprocess import Popen, PIPE, STDOUT


class FileReader(threading.Thread):

    def __init__(self, fd, queue):
        threading.Thread.__init__(self)
        self._fd = fd
        self._queue = queue

    def run(self):
        for line in iter(self._fd.readline, ''):
            self._queue.put(line)

    def eof(self):
        return not self.is_alive() and self._queue.empty()


def send_metrics(**kwargs):
    host = os.getenv('HOST',socket.gethostname())
    task = os.getenv('TASK','noname')
    taskid = os.getenv('TASKID','noid')
    p = Popen(["/usr/lib/fluent/ruby/bin/fluent-cat", "shedu.%s.%s.%s" % (host, task, taskid)], stdin=PIPE)
    p.communicate(input=json.dumps(kwargs))

def main():
    process = Popen(["/bin/bash", sys.argv[1]], stdout=PIPE, stderr=PIPE)
    stdout_q = Queue.Queue()
    stderr_q = Queue.Queue()
    stdout_r = FileReader(process.stdout, stdout_q)
    stderr_r = FileReader(process.stderr, stdout_q)
    stdout_r.start()
    stderr_r.start()
    while True:
        while not stdout_r.eof() or not stderr_r.eof():
            if not stdout_q.empty():
                send_metrics(stdout=stdout_q.get())
            if not stderr_q.empty():
                send_metrics(stderr=stderr_q.get())
        if process.poll() is not None:
            break
        time.sleep(1)
    stdout_r.join()
    stderr_r.join()
    process.stdout.close()
    process.stderr.close()
    send_metrics(exitcode=process.returncode)

if  __name__ ==  "__main__" :
    try:
        pid = os.fork()
        if pid > 0:
            sys.exit(0)
    except OSError, e:
        sys.stderr.write("fork #1 failed: %d (%s)\n" % (e.errno, e.strerror))
        sys.exit(1)
    os.setsid()
    os.umask(0)
    try:
        pid = os.fork()
        if pid > 0:
            sys.exit(0)
    except OSError, e:
        sys.stderr.write("fork #2 failed: %d (%s)\n" % (e.errno, e.strerror))
        sys.exit(1)
    sys.stdout.flush()
    sys.stderr.flush()
    si = file('/dev/null', 'r')
    so = file('/dev/null', 'a+')
    se = file('/dev/null', 'a+', 0)
    os.dup2(si.fileno(), sys.stdin.fileno())
    os.dup2(so.fileno(), sys.stdout.fileno())
    os.dup2(se.fileno(), sys.stderr.fileno())
    main()
