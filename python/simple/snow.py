#!/usr/bin/env python

# Snow in the CLI!
# Issues: if screen has big height, when flakes are colored
# screen starts to jitter
# MZvk 2019

import sys, time, os, random

rows, cols = [int(x) for x in os.popen('stty size', 'r').read().split()]
linebuffer = [' ' * cols] * rows
flaketype = '*#.,` -~\'oO0'
flakeclr  = ['97', '37', '90', '30', '96', '94']

def getflake():
  lshft = random.randint(0, 3)
  return '{}{}{}'.format(' ' * lshft, flaketype[random.randint(0, len(flaketype)) % len(flaketype)], ' ' * (3 - lshft))

def trimline(line):
  return line[:cols]
#  nline = ''
#  for chrs in line[:cols]:
#    nline = '{}\033[{}m{}\033[0m'.format(nline, flakeclr[random.randint(0, len(flakeclr)) % len(flakeclr)], chrs) if chrs != ' ' else '{}{}'.format(nline, chrs)
#  return nline

def genline():
  return ''.join([getflake() for flake in xrange((cols + 1)/4)])

try:
  while 1:
    linebuffer.pop(0)
    linebuffer.append(trimline(genline()))
    print '\n'.join(reversed(linebuffer))
    time.sleep(1)
except KeyboardInterrupt:
  sys.exit()
