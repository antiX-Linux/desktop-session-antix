#!/usr/bin/env python
#Search and replace

import getopt
import sys
import re
import os

def print_usage(exit_code = 1):
  print """Usage: %s [options]
Options
  --file        The file that you would like to modify
  --from        The original line we are searching for
  --to          What we are changing the line to
  """ % sys.argv[0]
  sys.exit(exit_code)

def replace(FILE,FROM,TO):
    TEMP_FILE='/tmp/temp.txt'
    text = file((TEMP_FILE), "a")
    for line in open(FILE, "r").xreadlines():
        if re.search(r'%s' % (FROM), line):
            text.write (TO+"\n") 
        else:
            text.write (line) 
    text.close()
    os.system("mv %s %s" % ((TEMP_FILE), (FILE)))
    


FILE = ''
FROM = ''
TO = ''

try: opts, args = getopt.getopt(sys.argv[1:], "", ("file=", "from=", "to="))
except getopt.GetoptError: print_usage()


for o, v in opts:
    if o == "--file": FILE = v
    elif o == "--from": FROM = v
    elif o == "--to": TO = v
    
replace(FILE, FROM, TO)
