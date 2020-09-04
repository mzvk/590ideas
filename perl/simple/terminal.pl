#!/usr/bin/env perl

use v5.10;
use warnings;
use strict;
use Data::Dumper;

## Simple "input" terminal
## Mzvk 2019

my @data;
print "\033[31mPaste input, ^D to end:\033[0m\n";
while(my $picks = <STDIN>) {
  chomp $picks;
  push @data, $picks;
}

say +Dumper \@data;
