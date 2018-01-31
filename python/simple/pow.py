#!/usr/bin/env python

## Calculates exponentiation with base of 2 and variable exponent
## Mzvk 2017

import sys

try:
  power = (2**i for i in xrange(int(sys.argv[1]) + 1))
except (ValueError, IndexError):
  print 'Incorrect input'
  sys.exit()

for idx, res in enumerate(power):
  print '2^{:<3} = {}'.format(idx, res)
