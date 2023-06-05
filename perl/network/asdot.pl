#!/usr/bin/env perl

## as-dot <=> as-plain convertion
## Mzvk 2019

## RFC5396
## asdot+  - represents ASN as two 16bit integers joined by .
## asplain - represents ASN as single 32bit integer
## asdot   - represents ASN as asplain if ASN < 65536 and as asdot+ when ASN > 65535

use strict refs;
use warnings;

die "No input.\n"if $#ARGV < 0;

for (@ARGV){
  my $org = $_;
  if(m/^([0-9]{0,5})\.([0-9]{0,5})$/ && ($1 | $2) && $1 < 65536 && $2 < 65536){
    printf "[AS-DOT+]  %s: %s\n", $org, ($1 << 16) + $2; 
  } elsif(m/^[1-9][0-9]{0,9}$/ && $_ <= 4294967295){
    printf "[AS-PLAIN] %s: %s.%s\n", $org, ($_ >> 16), ($_ & 0xFFFF);
  } else { die "ASN Is neither AS-PLAIN [1-4294967295] nor AS-DOT+ [(0-65535).(0-65535)] or equals 0!\n"; }
}
