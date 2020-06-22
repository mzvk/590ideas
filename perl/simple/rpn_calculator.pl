#!/usr/bin/env perl

## Calculates the result value of given RPN equation.
## Mzvk 2020

use v5.10;
use strict;
use warnings; 

my @stack;
my $ref;
my %omap = ('+' => [\&add, 2], '-' => [\&sbs, 2], 
            '*' => [\&mul, 2], '/' => [\&div, 2], 
            '^' => [\&pow, 2], '%' => [\&mod, 2],
            '++' => [\&inc, 1], '--' => [\&dec, 1]);

help() if scalar @ARGV < 1;
die "Incorrect RPN notation.\n" if $ARGV[0] !~ m/^[0-9+\-\/* ,^%]+$/;

my @input = split / |,/, $ARGV[0];
while(@input){
   if($input[0] =~ m/^[0-9]+$/) { push @stack, shift @input }
   else { 
       $ref = shift @input;
       die "$ref <- Token not recognized!\n" unless exists $omap{$ref};
       die "Calculation stack overflow! Requiring ".$omap{$ref}[1].", current size: ".(scalar @stack)."\n" unless validstck($omap{$ref}[1]);
       push @stack, $omap{$ref}[0](splice(@stack, -1 * $omap{$ref}[1]));
   }
}

say "Result: " . (shift @stack);

sub validstck { return scalar @stack >= (shift // 0) ? 1 : 0; }
sub help { 
   die "Usage $0 <rpn equation>\n\nSupported operators: \n +  : addition\n -  : substraction\n *  : multiplication\n /  : division\n",
       " ^  : power\n %  : modulus\n ++ : increment\n -- : decrement\n";
}
## math functions ##
sub add { return $_[1] +  $_[0] }
sub sbs { return $_[0] -  $_[1] }
sub mul { return $_[1] *  $_[0] } 
sub div { return $_[0] /  $_[1] }
sub pow { return $_[0] ** $_[1] }
sub mod { return $_[0] %  $_[1] }
sub inc { return $_[0] + 1 }
sub dec { return $_[0] - 1 }
