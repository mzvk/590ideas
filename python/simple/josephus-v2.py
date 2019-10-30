#!/usr/bin/env python

# Other solution to the "Josephus problem"
# This was based on the 15 Turks and 15 Christians, but can be used for any combination.
# It takes number of people, number of survivors and which position should be killed each iteration.
# Mzvk @ 2019

import sys

def argpars():
   try:
      if not len(sys.argv[1:]) == 3: raise ValueError
      return [int(x) for x in sys.argv[1:]]
   except ValueError:
      print "usage: {} <number_of_people> <kill_step> <number_of_survivors>".format(sys.argv[0])
      sys.exit()

def getnext(n, k, m):
   alive = [x for x in xrange(1, n+1)]
   ptr = (k - 1) % n
   while(len(alive) > m):
      alive.pop(ptr)
      ptr = (ptr + k - 1) % len(alive)
   return alive

args = argpars()
print "This position(s) would be alive: {}".format(getnext(args[0], args[1], args[2]))
