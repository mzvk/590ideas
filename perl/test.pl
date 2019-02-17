#!/usr/bin/env perl

use strict;
use warnings;

### OWN MODULES ###
use lib "/home/mzvk/git590/perl/GSA";
use utils qw(str2int int2str msk2len len2msk);

print "custom module loaded!\n";

print str2int('255.255.255.255')."\n";
print int2str(1)."\n";
print len2msk(30)."\n"
