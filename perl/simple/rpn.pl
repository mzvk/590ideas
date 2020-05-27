#!/usr/bin/env perl

## Converts expression from RPN (Reverse Polish Notation) postfix notation to the infix notation.
## Mzvk 2020

use v5.10;
use strict;
use warnings; 

my $output = '';
my @stack;
my ($f, $s);

die "No input, please submit equation in RPN notation.\n" if scalar @ARGV < 1;
die "Incorrect RPN notation.\n" if $ARGV[0] !~ m/^[0-9+\-\/* ,]+$/;

#my @input = split //, $inp =~ s/ |,//gr;
my @input = split / |,/, $ARGV[0];
while(@input){
   if($input[0] =~ m/[0-9]/) { push @stack, shift @input }
   else { 
       ($f, $s) = splice(@stack, -2);
       push @stack, "($f " . (shift @input) . " $s)";
   }
}

say "POSTFIX NOTATION: $ARGV[0]";
say "  INFIX NOTATION: " . shift @stack;
