#!/usr/bin/env python3

## Pseudo crypto module for Juniper weak password
## Mzvk 2017

from re import match
from random import randint

#juniper t9 vigenere
jvig = (0x51,0x7a,0x46,0x33,0x6e,0x36,0x2f,0x39,0x43,0x41,0x74,0x70,0x75,0x30,0x4f,0x42,0x31,0x49,0x52,0x45,
        0x68,0x63,0x53,0x79,0x72,0x6c,0x65,0x4b,0x76,0x4d,0x57,0x38,0x4c,0x58,0x78,0x37,0x4e,0x2d,0x64,0x56,
        0x62,0x77,0x73,0x59,0x32,0x67,0x34,0x6f,0x61,0x4a,0x5a,0x47,0x55,0x44,0x6a,0x69,0x48,0x6b,0x71,0x2e,
        0x6d,0x50,0x66,0x35,0x54)

#juniper t9 pad lenght
jjnk = (0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x02,0x02,0x02,0x02,0x02,
        0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x01,0x01,0x01,0x01,0x01,
	0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00)

#juniper t9 moduli
jmod = ((0x01,0x04,0x20),(0x01,0x10,0x20),(0x01,0x08,0x20),
        (0x01,0x40),(0x01,0x20),(0x01,0x04,0x10,0x80),(0x01,0x20,0x40))

jid = "$9$"

def juniper9Decrypt(inputHash):
   output = ""
   prevPos = juniper9Check(inputHash)
   if prevPos != 0:
     inputHash = inputHash[4+jjnk[prevPos]:]
     while inputHash:
        nibs = jmod[len(output) % len(jmod)]
        if not len(inputHash[:len(nibs)]) == len(nibs):
           print("WARNING - Incorrect Juniper type9 string, ran out of characters.")
           return ""
        deChr = 0
        for id, refch in enumerate(inputHash[:len(nibs)]):
            deChr += ((jvig.index(ord(refch)) - prevPos) % len(jvig) - 1) * jmod[len(output) % len(jmod)][id]
            prevPos = jvig.index(ord(refch))
        output += chr(deChr % 256)
	inputHash = inputHash[len(nibs):]
   return output

def juniper9Encrypt(inputString, index=''):
   if index == "": idx = jvig[randint(0, len(jvig) - 1)]
   else: idx = jvig.index(ord(index))
   output = jid + chr(idx)
   for i in range(0, jjnk[jvig.index(idx)]):
      output += chr(jvig[randint(0, len(jvig) - 1)])
   prevPos = jvig.index(idx)
   for idx, sChar in enumerate(inputString):
      sChar = ord(sChar)
      gap = []
      for encMod in reversed(jmod[idx % len(jmod)]):
         gap.append(sChar / encMod)
         sChar %= encMod
      for igap in list(reversed(gap)):
         igap += prevPos + 1
         prevPos = igap
         output += chr(jvig[igap % len(jvig)])
   return output

def juniper9Check(inputHash):
   prevPos = 0
   if len(inputHash) < 8 or inputHash[:3] != jid:
     print("WARNING - Incorrect Juniper type9 string.")
   else:
     for refch in [ord(x) for x in inputHash[3:]]:
        if not refch in jvig:
           print("WARNING - Incorrect Juniper type9 string, incorrect characters.")
           return 0
     prevPos = jvig.index(ord(inputHash[3:4]))
   return prevPos

if __name__ == '__main__':
  pass
