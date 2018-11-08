#!/usr/bin/env python
import re, sys

## Simple IPv4 address validator, wanted to use radix, but overhead is just not worth it - for single run
## Used really to test IPv4 regular expression
## Mzvk 2018

#sys.exit:
## 0  - valid address
## 10 - not valid
## 20 - on ignored list

ipv4_regex = r'^(?:(?=((?:25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\.))\1){3}(?:25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$'
ignored_list = {'0.0.0.0/8':       'THIS network [RFC1122]',
                '10.0.0.0/8':      'Private [RFC1918]',
                '100.64.0.0/10':   'Carrier NAT [RFC6598]',
                '127.0.0.0/8':     'Loopback [RFC1122]',
                '169.254.0.0/16':  'Link local [RFC3927]',
                '172.16.0.0/12':   'Private [RFC1918]',
                '192.0.0.0/24':    'IETF Protocol Assigements [RFC6890]',
                '192.0.2.0/24':    'TEST-NET-1 [RFC5737]',
                '192.168.0.0/16':  'Private [RFC1918]',
                '198.18.0.0/15':   'Benchmarking [RFC2544]',
                '198.51.100.0/24': 'TEST-NET-2 [RFC5737]',
                '203.0.113.0/24':  'TEST-NET-3 [RFC5737]',
                '224.0.0.0/4':     'Multicast [RFC0919]',
                '240.0.0.0/4':     'Reserved [RFC1112]'}

def str2int(ipStr):
  return reduce((lambda x, y: x | y), [int(oct) << (24 - 8 * idx) if int(oct) < 256 and int(oct) >= 0 else 'x' for idx, oct in enumerate(ipStr.split('.'))])

def len2msk(masklen):
  return reduce((lambda x,y: x | y) ,[1 << bitp for bitp in xrange(32, 31 - masklen, -1)])

if len(sys.argv[1:]) > 0:
  if re.match(ipv4_regex, sys.argv[1]):
    for tpl in ignored_list:
      tpl = tpl.split('/')
      if (str2int(sys.argv[1]) & len2msk(int(tpl[1]))) == str2int(tpl[0]):
        print "{} -- ignored: {}".format(sys.argv[1], ignored_list['/'.join(tpl)])
        sys.exit(20)
    print "{} -- valid".format(sys.argv[1])
    sys.exit(0)
  else:
      print "{} -- not valid".format(sys.argv[1])
      sys.exit(10)
