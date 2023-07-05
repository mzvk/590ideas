#!/usr/bin/env python3

## Mersenne Twister PRNG (algorithm created by Makoto Matsumo and Takuji Nishimura)
## 64bit version
## Mzvk 2023

import sys

_mtws = 64                                   # state word size
_mtts = 312                                  # state table size
_mtsp = 156                                  # state table step
_mtbm = ((29, 0x5555555555555555), (17, 0x71d67fffeda60000),
         (37, 0xfff7eee000000000), (43, 0xffffffffffffffff))

bman = {'<<': lambda n,b,m: (n << b) & m, '>>': lambda n,b,m: (n >> b) & m}

mt     = [0] * _mtts
idx    = _mtts + 1
mtmask = (1 << _mtws - 1) - 1
u64cll = 2 ** _mtws - 1
wcmask = u64cll ^ mtmask

def seed(seed):
  mt[0] = seed & u64cll
  for i in range(1, _mtts):
    mt[i] = (0x5851f42d4c957f2d * (mt[i-1] ^ (mt[i-1] >> (_mtws - 2))) + i) & u64cll

def twist():
  for i in range(_mtts):
    bits = (mt[i] & wcmask) | (mt[(i+1) % _mtts] & mtmask)
    mt[i] = mt[(i + _mtsp) % _mtts] ^ (bits >> 1) ^ ((bits & 1) * 0xb5026f5aa96619e9)
  return 0

def get_num():
  global idx
  if idx >= _mtts: idx = twist()
  num = mt[idx]
  for (oper, bitm) in zip(['>>','<<','<<','>>'], _mtbm):  
    num ^= bman[oper](num, bitm[0], bitm[1])
  idx += 1
  return num
  
if __name__ == '__main__':
   try:
      seedv = int(sys.argv[1]) & 0xffffffffffffffff
      seed(seedv)
      print(get_num())
   except:
      print("Input must be a single number")
