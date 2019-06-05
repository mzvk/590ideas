#!/usr/bin/env perl

## Trying out prime checking regex - it works!
## Mzvk 2018

use strict;
use warnings;

die "No input.\n" unless @ARGV;
die "\"$ARGV[0]\" is not numeric.\n" if $ARGV[0] !~ /^\d+$/;
(1 x $ARGV[0]) =~ /^.?$|^(..+)\1+$/ || print "$ARGV[0] is prime\n";
