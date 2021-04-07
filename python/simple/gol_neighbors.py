#!/usr/bin/env python

# Simple script to visualize part of my terminal-based simulator of the Conway's GoL.
# It iterates over living cells, checking all its neighbors.
# Extensive use of ANSI escape codes. That was a developement version ;).
# MZvk 2019

import sys, time

flock = {0: 1, 1: 1, 5: 1, 7: 1, 20: 1, 25: 1, 35: 1}
_GRIDX = 6
_GRIDY = 6
nmap = [-_GRIDX+1,-_GRIDX,-_GRIDX-1,+1,_GRIDX+1,_GRIDX,_GRIDX-1,-1]

def eprint(txt):
  sys.stdout.write(txt)
  sys.stdout.flush()

eprint("\033[2J\033[H")
print "*** GAME GRID ***\n"
print "{}{}{}".format(' +-', '-' * (_GRIDX * 2 - 1), '-+ ')
for x in xrange(_GRIDX):
   print '{}{}{}'.format(' | ', ' '.join(['.'] * _GRIDY), ' | ')
print "{}{}{}".format(' +-', '-' * (_GRIDX * 2 - 1), '-+ ')

visited = []
while(1):
  for cell in flock:
    visited.append(cell)
    time.sleep(0.1)
    if cell >= _GRIDX * _GRIDY:
      eprint("\033[{};0H## Cell Index: {:03} is out of bound, ignored! ##".format(_GRIDY + 6, cell))
      continue
    x = cell / _GRIDX
    y = cell % _GRIDY
    eprint("\033[{};{}H\033[35m{}\033[0m".format(x+4, y*2+1+3, 'X'))
    eprint("\033[{};0H".format(_GRIDY + 6))
    print "## Cell Index: {:03}, Corridinates: [{:2}, {:2}] ##".format(cell, x, y)

    neighbors = set(nmap)
    result = []

    if(cell / _GRIDY == 0):          neighbors -= {-_GRIDX-1, -_GRIDX, -_GRIDX+1} ## upper
    if(cell / _GRIDY == _GRIDY - 1): neighbors -= { _GRIDX-1,  _GRIDX,  _GRIDX+1} ## lower
    if(cell % _GRIDX == 0):          neighbors -= {-_GRIDX-1,      -1,  _GRIDX-1} ## leftmost
    if(cell % _GRIDX == _GRIDX - 1): neighbors -= {-_GRIDX+1,       1,  _GRIDX+1} ## righmost

    time.sleep(0.1)
    for ngb in neighbors:
       xn = (cell + ngb) / _GRIDX
       yn = (cell + ngb) % _GRIDY
       eprint("\033[{};{}H\033[36m{}\033[0m".format(xn+4, yn*2+1+3, 'X'))
       eprint("\033[{};0H".format(_GRIDY + 7))
       print "## Highlight neighbor: [{:2}, {:2}] ##".format(xn, yn)
       time.sleep(0.1)

    time.sleep(0.1)
    for ngb in neighbors:
       xn = (cell + ngb) / _GRIDX
       yn = (cell + ngb) % _GRIDY
       eprint("\033[{};{}H{}".format(xn+4, yn*2+1+3, '\033[35mX\033[0m' if cell+ngb in visited and cell+ngb < cell else '.'))
       eprint("\033[{};0H".format(_GRIDY + 7))
       time.sleep(0.1)

  break
eprint("\033[{};0H".format(_GRIDY + 10))
