#!/usr/bin/env python

# Snow in the CLI!
# Issues: if screen has big height, when flakes are colored
# screen starts to jitter.

# intro weight to slow-start
# shading for slow-start?

# MZvk 2019

import sys, time, os, random

flaketype = '*#.,` -~oO0'
flakeclr  = ['97', '37', '90', '30', '96', '94']

def getflake():
  lshft = random.randint(0, 3)
  return '{}{}{}'.format(' ' * lshft, flaketype[random.randint(0, len(flaketype)) % len(flaketype)], ' ' * (3 - lshft))

def trimline(line):
  return ''.join(['\033[{}m{}\033[0m'.format(flakeclr[random.randint(0, len(flakeclr)) % len(flakeclr)], chrs) if chrs != ' ' else chrs for chrs in line[:cols]])

def genline():
  return ''.join([getflake() for flake in xrange((cols + 1)/4)])

rows, cols = [int(x) for x in os.popen('stty size', 'r').read().split()]
if rows * cols > 8000:
  print "Screen to big to display without jitter"
  sys.exit()
linebuffer = [' ' * cols] * rows

try:
  while 1:
    linebuffer.pop(0)
    linebuffer.append(trimline(genline()))
    print '\n'.join(reversed(linebuffer))
    time.sleep(0.25)
except KeyboardInterrupt:
  sys.exit()
