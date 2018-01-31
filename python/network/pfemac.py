#!/usr/bin/env python

#
# zvk@2018
# Converts MAC addresses from Juniper PFE to readable format
#

import sys, re

def s2i(ahex):
  return reduce((lambda x, y: x | y), [int(x) << (40 - 8 * idx) for idx, x in enumerate(ahex)])

def i2s(ihex):
  return ':'.join(['{:0>2x}'.format(ihex >> idx & 0xff).upper() for idx in [40, 32, 24, 16, 8, 0]])

def l2m(mskl):
  return reduce((lambda x,y: x | y) ,[1 << bitp for bitp in xrange(48, 47 - mskl, -1)])

def mmv(mac, mask):
  if(len(mac)*8 < int(mask)): print "\033[33m[warning]\033[0m Address is shorter then mask, padding with 0s."
  mk = l2m(int(mask))
  tc = s2i(mac)

  og = i2s(tc)
  lo = i2s(tc & mk)
  hi = i2s(tc | ~mk & 0xffffffffffffffff)

  if(lo == og): return ["{}/{}".format(og, mask), lo, hi]
  else:
    print "\033[31m[error]\033[0m Wrong address for /{} mask, returning assumed value.".format(mask)
    return ["{}/{}".format(lo, mask), lo, lo]

try:
  rep = re.search(r'^((?:(?:25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\.){0,5}(?:25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9]))/(4[0-8]|[1-3]?[0-9])$', sys.argv[1])
  if rep:
    _res = mmv(rep.group(1).split("."), rep.group(2))
    print "\nconverted: {}".format(_res[0])
    print   "lower:     {}".format(_res[1])
    print   "upper:     {}".format(_res[2])
  else:
     print "\033[31m[error]\033[0m Incorret format."
     sys.exit()
except IndexError:
  sys.exit()
