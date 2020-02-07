#!/usr/bin/env python

## XORSHIFT32 (algorithm by George Marsaglia)
## MZvk @ 2020

import sys

def xorshift32(state):
   state ^= state << 13
   state ^= state << 17
   state ^= state << 5
   return state & 0xffffffff

if __name__ == '__main__':
   try:
      seed = int(sys.argv[1]) & 0xffffffff
      print xorshift32(seed)
   except:
      print "Input must be a single number"
