#!/usr/bin/env python

import sys, re

def valCheck(value):
  grps = re.match(r'^01075369656D656E7302040000([0-9A-F]{4})03([0-9A-F]+)', value)
  if grps:
    return [grps.group(1), grps.group(2)]
  else:
    print "\033[31m[ERROR] Incorrect Option 43 hex string\033[0m"

def valTrans(value):
  sip = []
  for x in xrange(2, (int(value[:2], 16) + 1) * 2, 2):
    sip.append(chr(int(value[x:x+2], 16)))
  return ''.join(sip)

if __name__ == '__main__':
  try:
    optstr = valCheck(sys.argv[1].replace(':','').upper())
    print "VLAN ID    {}".format(int(optstr[0], 16))
    print "DLS addr.  {}".format(valTrans(optstr[1]))
  except IndexError:
    print "\033[31m[ERROR] No input value provided\033[0m"
