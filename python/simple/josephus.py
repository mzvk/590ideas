#!/usr/bin/env python

# Solution to the Josephus permutation (problem)
# Kind of hacky way, not following "math" equation
# It just wraps first bit to the end of number
# MZvk 2019


# solution to Josephus permutation

import sys, re

if not len(sys.argv[1:]) == 1: sys.exit()
if not re.match(r'^[0-9]+$', sys.argv[1]): sys.exit()

c = int(sys.argv[1])
print "Position avoiding execution: {}".format(((c & ~(2**(len(bin(c))-3))) << 1) + 1)
