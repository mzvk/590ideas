#!/usr/bin/env perl

## Custom padding function with extended functionality
## Possibility to padd trailing and leading characters (or both)
## Mzvk 2019

use strict refs;
use warnings;

sub custpadd {
  my ($tx, $pc, $pl, $dr) = @_;
  my $tpl = $pl - length($tx) > 0 ? $pl - length($tx) : 0;
  if($dr eq '<>') {
     return $pc x ($tpl/2) . $tx . $pc x ($tpl/2) . $pc x ($tpl%2);
  } else {
     return $dr eq '>' ? $tx . $pc x $tpl : $pc x $tpl . $tx;
  }
}

die "Invalid input.\nUsage $0 <text> <padding character> <total length of string, txt + padding>, '<direction [<,>,<>]>\n" if $#ARGV < 3;
die "$ARGV[2] is not numeric.\n" if $ARGV[2] !~ /^\d+$/;
die "Wrong direction, only supported are < - leading, > - trailing, <> - both.\n" unless $ARGV[3] =~ m/^(?:<(?<=<)>|[<>])$/;
print custpadd($ARGV[0], substr($ARGV[1],0,1), $ARGV[2], $ARGV[3]);
