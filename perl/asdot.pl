#!/usr/bin/env perl

## as-dot to as-plain convertion
## Mzvk 2019

use strict refs;
use warnings;

#4294967295

die "No input.\n"if !$ARGV[0];

if($ARGV[0] =~ m/^([0-9]{0,5})\.([0-9]{0,5})$/ && $1 & $2){ 
  print(($1 << 16) + $2 . "\n"); 
} elsif($ARGV[0] =~ m/^[1-9][0-9]{0,9}$/ && $ARGV[0] < 4294967295){ 
  print(($ARGV[0] >> 16) . "." . ($ARGV[0] & 0xFFFF) . "\n");
} else { die "ASN Is neither AS-PLAIN nor AS-DOT or value equals 0!\n"; }
