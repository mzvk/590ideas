#!/usr/bin/env perl

## as-dot <=> as-plain convertion
## Mzvk 2019

use strict refs;
use warnings;

die "No input.\n"if $#ARGV < 0;

for(@ARGV){
  my $org = $_;
  if(m/^([0-9]{0,5})\.([0-9]{0,5})$/ && ($1 | $2) && $1 < 65536 && $2 < 65536){
    printf "%s: %s\n", $org, ($1 << 16) + $2;
  } elsif(m/^[1-9][0-9]{0,9}$/ && $_ <= 4294967295){
    printf "%s: %s\n", $org, sprintf "%d.%d", ($_ >> 16), ($_ & 0xFFFF);
  } else { die "ASN Is neither AS-PLAIN [1-4294967295] nor AS-DOT [(0-65535).(0-65535)] or equals 0!\n"; }
}
