#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

my @mt = (0) x 624;
my $id = 625;
my ($hmask, $lmask) = (0x80000000, 0x7fffffff);

seed($ARGV[0]);
print get_num()."\n";

sub seed {
   my $seed = shift // 5489;
   $mt[0] = $seed & 0xffffffff;
   for(my $i = 1; $i < 624; $i++) {
      $mt[$i] = (0x6c078965 * ($mt[$i-1] ^ ($mt[$i-1] >> 30)) + $i) & 0xffffffff;
   }
}

sub twist {
   for(my $i = 0; $i < 624; $i++) {
      my $bits = ($mt[$i] & $hmask) | ($mt[($i+1) % 624] & $lmask);
      $mt[$i] = $mt[($i + 397) % 624] ^ ($bits >> 1) ^ (($bits & 1) * 0x9908b0df);
   }
   return 0;
}

sub get_num {
   $id = twist() if $id >= 624;
   my $num = $mt[$id];
   $num ^= ($num >> 11) & 0xffffffff;
   $num ^= ($num << 7 ) & 0x9d2c5680;
   $num ^= ($num << 15) & 0xefc60000;
   $num ^= ($num >> 18) & 0xffffffff;
   $id++;
   return $num
}
