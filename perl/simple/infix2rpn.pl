#!/usr/bin/env perl

## Converts expression from RPN (Reverse Polish Notation) postfix notation to the infix notation.
## Mzvk 2020

use v5.10;
use strict;
use warnings; 
use Data::Dumper;

my (@main_stack, @oper_stack);
my ($f, $s, $tc);

die "No input, please submit equation in RPN notation.\n" if scalar @ARGV < 1;
die "Incorrect RPN notation.\n" if $ARGV[0] !~ m/^[0-9+\-\/* ,()]+$/;

my @input = split / |,/, $ARGV[0];
while(@input){

   if($input[0] =~ m/^[0-9]$/) { 
      push @main_stack, shift @input; 
#      $tc++;
#      if($tc >= 2) { push @main_stack, pop @oper_stack; $tc -= 1; }
   }
   elsif($input[0] =~ m/\(/){ print "otwarty nawias! $input[0]\n"; exit;}
   elsif($input[0] =~ m/\)/){ print "zamkniety nawias! $input[0]\n"; exit;}
   else { 
      push @oper_stack, shift @input;      
   }
}

say "OPER STACK: ". +Dumper \@oper_stack;
say "MAIN STACK: ". +Dumper \@main_stack;

#push @main_stack, pop @oper_stack while(@oper_stack);

 #say "POSTFIX NOTATION: $ARGV[0]";
#say "  INFIX NOTATION: " . join(' ', @main_stack);

sub help {
   exit;
}
