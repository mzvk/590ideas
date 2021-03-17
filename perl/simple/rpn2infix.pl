#!/usr/bin/env perl

## Converts expression from RPN (Reverse Polish Notation) postfix notation to the infix notation.
## Mzvk 2020

use v5.10;
use strict;
use warnings; 

my @stack;
my ($fa, $sa, $o);

my %omap = ('+' => 0, '-' => 0, '*' => 2, '/' => 2, '^' => 4);

die "ERROR: No input, please submit equation in RPN notation.\n" if scalar @ARGV < 1;
die "ERROR: Incorrect RPN notation.\n" if $ARGV[0] !~ m/^[0-9+\-\/* ,^%]+$/;

my @input = split / |,/, $ARGV[0];
while(@input){
   if($input[0] =~ m/^[0-9]+$/) { push @stack, [shift @input, 100] }
   else { 
       ($fa, $sa) = splice(@stack, -2);
       $o = shift @input;
       push @stack, [(sprintf "%s %s %s", bracketizer($o, $fa), $o, bracketizer($o, $sa)), $omap{$o}]; 
   }
}

say "POSTFIX NOTATION: $ARGV[0]";
say "  INFIX NOTATION: " . $stack[0][0];

sub bracketizer {
   my ($o, $f) = @_;
   return $omap{$o} > $f->[1] ? "($f->[0])" : $f->[0];
}
