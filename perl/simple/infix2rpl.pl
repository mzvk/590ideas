#!/usr/bin/env perl

# Converts expression from infix to the RPN (Reverse Polish Notation) postfix notation.
# Uses Dijkstra shunting-yard algorithm as a base. 
# Mzvk 2020

use v5.10;
use warnings;
use strict;
use Data::Dumper;

my (@stack, @output);
my %omap = ('+' => 1, '-' => 1, '*' => 2, '/' => 2, '%' => 2, '^' => 3, '(' => 0);

die "\033[31mERROR:\033[0m No input, please submit equation in infix notation.\n" if scalar @ARGV < 1;
#die "\033[31mERROR:\033[0m Incorrect infix notation.\n" if $ARGV[0] !~ m/^[0-9+\-\/* ^%()]+$/;

printf "..INFIX NOTATION: %s\n\n", $ARGV[0];
my @input = esplit($ARGV[0]);

while(@input){
   if    ($input[0] =~ /^[0-9]+$/) { say '<- PUSH TOKEN TO OUTPUT -- '. $input[0]; push @output, shift @input; }
   elsif ($input[0] =~ /^[+\-*\/(^]$/) { 
      if(scalar @stack > 0 && $omap{$stack[-1]} >= $omap{$input[0]}) { 
         say '-> POP  STACK TO OUTPUT -- ' . $stack[-1];
         push @output, pop @stack; 
         say '<- PUSH TOKEN TO STACK  -- ' . $input[0];
         push @stack, shift @input; 
      } else { say '<- PUSH TOKEN TO STACK  -- ' . $input[0]; push @stack, shift @input; }
   }
   elsif ($input[0] eq ')') {
      say '## POP  STACK UNTIL ( FOUND';
      shift @input;
      while (scalar @stack && $stack[-1] ne '(') { say '-> POP  STACK TO OUTPUT -- ' . $stack[-1]; push @output, pop @stack; }
      say '## DISCARD (';
      shift @stack;
   }
   else {
      print "\033[38;5;202mWARNING:\033[0m Incorrect element '$input[0]' has been discarded.\n";
      shift @input;   
   }
}

printf "\nPOSTFIX NOTATION: %s %s", join(" ", @output), join(" ", reverse @stack);

sub esplit {
   my @instr = split //, shift;
   my @output;
   my $bracket = 0;
   my $token = '';
   my $float = 0;

   for my $sigil (@instr) {
      next if $sigil eq ' ';
      if($sigil =~ m/^[0-9]$/) {
         $token .= $sigil;
         next;
############ [ normalize number to use , as a decimal seperator ] 
      } elsif($sigil =~ m/^[,.]$/) {
         die "dwa przecinki?\n" if $float;
         $token .= $sigil;
         $float++;
         next;
      } elsif($sigil eq '(') { 
         $bracket++;
      } elsif($sigil eq ')') { 
         $bracket--;
      }
      if($float) { $token =~ s/\./,/g; $float = 0 }
      push @output, $token if $token;
      push @output, $sigil;
      undef $token;
   }
   push @output, $token if $token;
   die "[ERROR] Too many open brackets detected [$bracket].\n" if $bracket > 0;
   die "[ERROR] Too many closed brackets detected [".-$bracket."].\n" if $bracket < 0;
   print +Dumper \@output;
   return @output;
}
