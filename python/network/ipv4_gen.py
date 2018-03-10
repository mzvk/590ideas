#!/usr/bin/env python

# IPv4 address generator (written to learn generator)
# MZvk 2018

from random import randint
import sys

def genipv4():
  while True:
    dump = [str(randint(200,255)) if x > 0 else str(randint(1, 223)) for x in xrange(4)]
    yield '.'.join(dump)

if __name__ == '__main__':
  generator = genipv4()
  if(len(sys.argv[1:]) > 0):
    try:
      for x in xrange(int(sys.argv[1])):
        print next(generator)
    except ValueError:
      pass
