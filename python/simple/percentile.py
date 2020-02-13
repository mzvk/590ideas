#!/usr/bin/env python

## Calculates any percentile for the given data set
## using 8 different methods
## Mzvk 2020

import random, sys, re

def genset(n):
   return [random.randint(0, 100) for x in xrange(n)]

def indexing(offset = 0, shift = 0):
   i = (len(data_set) + offset) * float(percentile)/100 + shift
   if(i >= len(data_set)): i = len(data_set) - 1
   return (i - int(i), int(i))

def waxn():
   (f, i) = indexing()
   return (1 - f) * data_set[i-1] + f * data_set[i]

def waxnp():
   (f, i) = indexing(1)
   return (1 - f) * data_set[i-1] + f * data_set[i]

def edf():
   (f, i) = indexing()
   return data_set[i] if f else data_set[i-1]

def edfa():
   (f, i) = indexing()
   return data_set[i] if f else float(data_set[i] + data_set[i-1])/2

def edfi():
   (f, i) = indexing(-1)
   return data_set[i] + f*(data_set[i+1] - data_set[i]) if f else data_set[i]

def co():
   (f, i) = indexing(0, 0.5)
   return data_set[i-1]

def sgt():
   (f, i) = indexing(1)
   return f*data_set[i-1] + (1-f) * data_set[i] if f else data_set[i-1]

def mse():
   (f, i) = indexing(1)
   if(f <  0.5): return data_set[i-1]
   if(f == 0.5): return float(data_set[i] + data_set[i-1])/2
   if(f >  0.5): return data_set[i]

methods = [['Weighted Avarage at X[np]', waxn], ['Weighted Avarage at X[(n+1)p]', waxnp], ['Empirical Distribution Function', edf],
           ['Empirical Distribution Function - Averaging', edfa], ['Empirical Distribution Function - Interpolation', edfi], ['Closest Observation', co],
           ['TrueBasic - Statistics Graphics Toolkit', sgt], ['MS Excel (Old)', mse]]
data_set = []

if(sys.argv[1:]):
   try:
      percentile = int(sys.argv[1])
      if percentile > 99 or percentile < 1: raise ValueError
   except ValueError:
      sys.exit("Percentile must be integer from range 1-99.")
else: percentile = 75

if(sys.argv[2:]):
   if(re.match(r'^[0-9]+(,[0-9]+){2,}$', sys.argv[2])):
      data_set = sorted([int(x) for x in sys.argv[2].split(',')])
if not data_set:
   data_set = sorted(genset(30))

print "DATA SET: {}\n".format(data_set)
for method in methods:
   print "#### {}\n{}th percentile of data set: {}\n".format(method[0], percentile, method[1]()).upper()
