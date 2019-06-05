#!/usr/bin/env perl

## Custom padding function
## Mzvk 2017

use strict refs;
use warnings;

sub custpadd {
  my ($tx, $pc, $pl) = @_;
  return $tx . $pc x ( $pl - length($tx) > 0 ? $pl - length($tx) : 0);
}

print custpadd($ARGV[0], $ARGV[1], $ARGV[2]);
