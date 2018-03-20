#!/usr/bin/env python

# Simple input terminal
# MZvk 2018

def termInput():
  cli = []
  print "\033[31mPaste input, ^D to end:\033[0m"
  while True:
    try:
      input = raw_input()
      if input:
        cli.append(input)
    except EOFError:
      return cli

print termInput()
