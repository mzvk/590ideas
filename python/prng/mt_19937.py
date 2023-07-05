#!/usr/bin/env python3

## Mersenne Twister PRNG (algorithm created by Makoto Matsumo and Takuji Nishimura)
## Mzvk 2020

import sys

_mtws = 32                                   # state word size
_mtts = 624                                  # state table size
_mtsp = 397                                  # state table step
_mtbm = ((11,0xffffffff),(7 ,0x9d2c5680),
         (15,0xefc60000),(18,0xffffffff))
bman = {'<<': lambda n,b,m: (n << b) & m, '>>': lambda n,b,m: (n >> b) & m}

mt     = [0] * _mtts
idx    = _mtts + 1
mtmask = (1 << _mtws - 1) - 1
u32cll = 2 ** _mtws - 1
wcmask = u32cll ^ mtmask

def seed(seed = 5489):
   mt[0] = seed & u32cll
   for i in range(1, _mtts):
      mt[i] = (0x6c078965 * (mt[i-1] ^ (mt[i-1] >> (_mtws - 2))) + i) & u32cll

def twist():
   for i in range(_mtts):
      bits = (mt[i] & wcmask) | (mt[(i+1) % _mtts] & mtmask)
      mt[i] = mt[(i + _mtsp) % _mtts] ^ (bits >> 1) ^ ((bits & 1) * 0x9908b0df)
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
    seedv = int(sys.argv[1]) & 0xffffffff
    seed(seedv)
    print(get_num())
  except:
    print("Input must be a single number")
