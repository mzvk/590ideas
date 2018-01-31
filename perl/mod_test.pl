#!/usr/bin/perl

## Small script to check if perl modules can be loaded
## Also some things were written to learn perl a little bit
## MZvk 2016

use feature qw(say);
use strict;
use warnings;
use Getopt::Long;

my $verbose = 0;
my $list = 0;
my @failed;
my @success;

GetOptions (
   "verbose" => \$verbose,
   "list"    => \$list,
) or exit 255;

if($verbose and $list) {
	say "cannot work in list and verbose mode, clearing verbose flag!";
	$verbose = 0;
}

if($#ARGV < 0) {die "STDERR: No arguemnts\n";}
#print $#ARGV + 1; 

foreach (@ARGV){
   if(!$list) {say "-" x `tput cols` ."\nTrying to load module -> $_";}
   try_module($_);
}
if($list){
   say "\nResult list:";
   say "** Modules loaded successfully: ".scalar @success;
   for (@success) {say "- ".$_;}
   say "** Modules failed to load: ".scalar @failed;
   for (@failed) {say "- ".$_;}
}
say "";
exit(0);

sub try_module {
   eval("use $_");
   if($@) {
      if($verbose) {say "cannot load module, detailed error:\n".$@; 
      } else {
         if(!$list) {say "\033[33mFailed to load \"$_\"!\033[0m";}
         if($list) {push @failed, $_;}
      }
   } else {
      if(!$list) {say "$_ loaded sucessfully!";} 
      if($list) {push @success, $_;}  
   }
}
