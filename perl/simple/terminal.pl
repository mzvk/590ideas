#!/usr/bin/env perl

use v5.10;
use warnings;
use strict;
use Data::Dumper;

my @data;
while(my $picks = <STDIN>) {
  chomp $picks;
  push @data, $picks;
}

say +Dumper \@data;
