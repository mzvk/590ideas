#!/usr/bin/env python

import sys, random

_bf = 0
_dc = 0

OPT_LIST = {'bruteforce': '_bf', 'decrypt': '_dc', 'key': 'cip_key'}
OPT_VALS = ['key']

key_map = map(chr, range(65,91))
cip_key = random.randint(1, len(key_map) - 1)

def arg_parse(arglist):
  string = []
  for arg in arglist:
    if arg[:2] == '--':
      arg = arg[2:].split('=')
      if arg[0] in OPT_LIST and len(arg) < 3:
        if len(arg) > 1:
          if arg[0] not in OPT_VALS:
             print '\033[33m[warn]\033[0m Argument "{}" does not require a value, value discarded.'.format(arg[0])
             globals()[OPT_LIST[arg[0]]] = 1
          else:
             try: globals()[OPT_LIST[arg[0]]] = int(arg[1]) if int(arg[1]) < len(key_map) else 1
             except ValueError: print '\033[33m[warn]\033[0m Argument "{}" value must be integer'.format(arg[0])
        else:
          if arg[0] in OPT_VALS:
            print '\033[33m[warn]\033[0m Argument "{}" needs value specified [{}=<value>]. Argument ignored.'.format(arg[0], arg[0])
          else:
            globals()[OPT_LIST[arg[0]]] = 1
      else: print '\033[33m[warn]\033[0m Unknown argument "{}" or multiple value assigement, argument is ignored [sub arg len: {}].'.format(arg[0], len(arg))
    else:
       string.append(arg)
  return string

def if_low(char):
  return 1 if ord(char) > 96 and ord(char) < 123 else 0

# for decryption, key needs to be negated
def crypt(txt, nkey=cip_key):
  cipher = []
  for char in txt:
    tchar = char.upper() if if_low(char) else char
    ochar = char if tchar not in key_map else key_map[(ord(tchar) - ord(key_map[0]) + nkey) % len(key_map)]
    cipher.append(ochar.lower() if tchar != char else ochar)
  return ''.join(cipher)

def bforce(cphr):
  for key in xrange(1, len(key_map)):
    print " {:2d} - {}".format(key, crypt(cphr, -key))

def main():
  if not (len(sys.argv[1:]) > 0):
    print '\033[31m[error]\033[0m No input provided.'
    sys.exit()

  string = ' '.join(arg_parse(sys.argv[1:]))
  if not string:
    print '\033[31m[error]\033[0m No string provided to encryt/decrypt.'
    sys.exit()

  if _dc and _bf:
    print "\nbrute force:"
    bforce(string)
  elif _dc:
    print "key value: {}".format(cip_key)
    print crypt(string, -cip_key)
  else:
    print crypt(string, cip_key)

main()
