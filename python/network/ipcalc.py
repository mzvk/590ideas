#!/usr/bin/env python

import sys, re, getopt
from functools import reduce

nline = 30
padding = False
form = None

def usage():
  print """\033[37mby MZvk v1.0

--[USAGE]---------------------------------------------------------------
$ __script_name__ <params> <args>
-- params:
 -p: flag, enables padding with 0 so each octet is exactly 3 digits long
     work only for default formating (exclusive with -h, -b)
 -b: flag, prints output in binary (exclusive with -h, first is used)
 -h: flag, prints output in hex (exclusive with -b, first is used)
-- args:
  Arguments should be provided in <ip>/<mask> format.
------------------------------------------------------------------------\033[0m"""
  sys.exit()

def str2int(ipStr):
  return reduce((lambda x, y: x | y), [int(oct) << (24 - 8 * idx) if int(oct) < 256 and int(oct) > 0 else 'x' for idx, oct in enumerate(ipStr.split('.'))])

def int2str(ipInt):
  if form == 'hex':
    return '.'.join(['{:02x}'.format(ipInt >> idx & 0xff).upper() for idx in [24, 16, 8, 0]])
  elif form == 'bin':
    return '.'.join(['{:08b}'.format(ipInt >> idx & 0xff) for idx in [24, 16, 8, 0]])
  elif padding == True:
    return '.'.join(['{:03d}'.format(ipInt >> idx & 0xff) for idx in [24, 16, 8, 0]])
  return '.'.join(['{}'.format(ipInt >> idx & 0xff) for idx in [24, 16, 8, 0]])

def len2msk(masklen):
  return reduce((lambda x,y: x | y) ,[1 << bitp for bitp in xrange(32, 31 - masklen, -1)])

def msk2len(mask):
  return 32 - sum([(0xff ^ int(oct)).bit_length() for oct in mask.split('.')])

if not len(sys.argv[1:]) > 0:
  usage()

try:
  opts, args = getopt.getopt(sys.argv[1:], 'pbht')
except getopt.GetoptError:
  print '\033[31mIncorrect input parameter.\033[0m'
  usage()

for option, value in opts:
  if option[1:] == 'p': padding = True
  elif option[1:] == 'h' and not form:
    form = 'hex'
  elif option[1:] == 'b' and not form:
    form = 'bin'

for ip in args:
  ipin = ip.split('/')
  try:
    mask = len2msk(int(ipin[1]))
    netaddr = str2int(ipin[0]) & mask
    bcstaddr = str2int(ipin[0]) | ~mask & 0xffffffff
  except (ValueError, TypeError, IndexError):
    print '\033[31m{} - Incorrect input value.\033[0m'.format(ipin)
    continue

  if form == 'hex':
    ipin[0] = '.'.join(['{:02x}'.format(int(oct)).upper() for oct in ipin[0].split('.')])
  elif form == 'bin':
    ipin[0] = '.'.join(['{:08b}'.format(int(oct)).upper() for oct in ipin[0].split('.')])
    nline = 75
  elif padding == True:
    ipin[0] = '.'.join(['{:03d}'.format(int(oct)).upper() for oct in ipin[0].split('.')])

  print '+'+'-'*20+'+'+'-'*nline
  print '| prefix             | {}'.format(ipin[0])
  print '| subnet mask        | {}'.format(int2str(mask))
  print '| subnet wildcard    | {}'.format(int2str(~mask))
  print '| subnet net address | {}'.format(int2str(netaddr))
  print '| subnet broadcast   | {}'.format(int2str(bcstaddr))
  print '| usable range       | {} - {}'.format(int2str(netaddr + 1), int2str(bcstaddr - 1))
  print '+'+'-'*20+'+'+'-'*nline
