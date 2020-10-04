#!/usr/bin/env python

# Simple terminal color tester
# MZvk 2020

import sys, time

color_map = [x for x in xrange(16,232)]
idx = 0

def clear_screen():
   sys.stdout.write('\033[J')
   sys.stdout.flush()

def set_cursor(x = 1, y = 1):
   sys.stdout.write('\033[{};{}H'.format(y, x))
   sys.stdout.flush()

large_text = """Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."""
set_cursor()
clear_screen()
for letter in large_text:
   try:
      sys.stdout.write('\033[38;5;{}m{}'.format(color_map[idx], letter))
      sys.stdout.flush()
      time.sleep(0.05)
      idx = (idx + 1) % (len(color_map))
   except KeyboardInterrupt:
      sys.stdout.write('\033[0m\n')
      sys.stdout.flush()
      break
