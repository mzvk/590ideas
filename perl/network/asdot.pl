#!/usr/bin/env perl

## as-dot <=> as-plain convertion
## Mzvk 2019

use strict refs;
use warnings;

die "No input.\n"if $#ARGV < 0;

if($ARGV[0] =~ m/^([0-9]{0,5})\.([0-9]{0,5})$/ && ($1 | $2) && $1 < 65536 && $2 < 65536){
  print(($1 << 16) + $2 . "\n"); 
} elsif($ARGV[0] =~ m/^[1-9][0-9]{0,9}$/ && $ARGV[0] <= 4294967295){
  print(($ARGV[0] >> 16) . "." . ($ARGV[0] & 0xFFFF) . "\n");
} else { die "ASN Is neither AS-PLAIN [1-4294967295] nor AS-DOT [(0-65535).(0-65535)] or equals 0!\n"; }
