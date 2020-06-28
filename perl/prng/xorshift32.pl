#!/usr/bin/env perl

## XORSHIFT32 (algorithm by George Marsaglia)
## Mzvk 2020

use strict;
use warnings;

die "No seed value.\n" unless @ARGV > 0;
print get_num($ARGV[0])."\n";

sub get_num {
   my $seed = shift;
   die "Seed value must be an integer.\n" unless $seed =~ m/^[0-9]+$/;
   $seed &= 0xFFFFFFFF;
   $seed ^= $seed << 13;
   $seed ^= $seed << 17;
   $seed ^= $seed << 5;
   return $seed & 0xFFFFFFFF;
}


