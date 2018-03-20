#!/usr/bin/env python

# Solution to the 'extended' 100 doors problem
# MZvk 2018

import sys

DEFAULT_DOORS = 100

try:
  doors = int(sys.argv[1]) if len(sys.argv[1:]) == 1 else DEFAULT_DOORS
except ValueError:
  doors = DEFAULT_DOORS

print [door for door in xrange(1, doors + 1) if not (door ** 0.5) % 1]
