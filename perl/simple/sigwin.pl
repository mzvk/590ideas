#!/usr/bin/env perl

## Trapping window change signal in PERL
## Mzvk 2020

use strict;
use warnings;

$SIG{WINCH} = sub { my ($w, $h) = getrc(); print "WHY CHANGE WINDOW SIZE? >:(! => $w x $h\n"; };

while(1){
   ;
}

sub getrc {
   qx(/bin/stty size) =~ m/^([0-9]+) +([0-9]+)$/;
   die "[Error]: Cannot retrieve screen size!\n" unless $1 && $2; 
   return $1, $2;
}
