#!/usr/bin/python

import subprocess
import traceback
from datetime import datetime
import time

while True:
    print '-----> STARTING NEW LOOP'
    try:
        #cmd = 'while true; do ab -n 100000 -c 5 -f TLS1.0 -Z ECDHE-ECDSA-AES256-SHA https://scaleout.demovip.avi.local/100k.dat & ab -n 100000 -c 5 -f TLS1.1 -Z ECDHE-ECDSA-AES256-SHA https://scaleout.demovip.avi.local/100k.dat & ab -n 100000 -c 5 -f TLS1.2 -Z ECDHE-ECDSA-AES256-SHA https://scaleout.demovip.avi.local/100k.dat; done'
        cmd = 'ab -n 100000 -c 2 https://photo.demo.ns.avi/photo'
        result = subprocess.check_output(cmd, shell=True)
        time.sleep(1)
    except:
        exception_text = traceback.format_exc()
        print(str(datetime.now())+' '+exception_text)
        print 'ERROR - restarting'
