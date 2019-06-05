#!/usr/bin/env perl

## Custom padding function
## Mzvk 2017

use strict refs;
use warnings;

sub custpadd {
  my ($tx, $pc, $pl) = @_;
  return $tx . $pc x ( $pl - length($tx) > 0 ? $pl - length($tx) : 0);
}

die "Invalid input.\nUsage $0 <text> <padding character> <total length of string, txt + padding>\n" if $#ARGV < 2;
die "$ARGV[2] is not numeric.\n" if $ARGV[2] !~ /^\d+$/;
print custpadd($ARGV[0], substr($ARGV[1],0,1), $ARGV[2]);
