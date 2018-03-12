#!/usr/bin/env python

# FizzBuzz as decorator function
# MZvk 2018

def fizzbuzz(end):
  def wrapper_generator():
    start = 0
    while start < end:
      start += 1
      if not start % 15: msg = 'FizzBuzz!'
      elif not start % 3: msg = 'Fizz!'
      elif not start % 5: msg = 'Buzz!'
      else: msg = ''
      yield '{:3d} \033[31m{}\033[0m'.format(start, msg)

  return wrapper_generator

test = fizzbuzz(100)
gen = test()

for x in gen:
  print x
