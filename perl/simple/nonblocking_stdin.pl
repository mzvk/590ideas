#!/usr/bin/perl
use warnings;
use strict;
use IO::Select;

## Script to translate and return normalized value of input from nonblocking STDIN
## Unfortunately I don't have all keycode mapped to ANSI escape codes :( [same applies to demo]
## Mzvk 2020

my $s = IO::Select->new();
$| = 1;
$s->add( \*STDIN );

system "stty -icanon -isig -echo time 0 min 1";
print "Non-blocking STDIN demo. Press ^C to terminate.\n";
while (1) {
   if(my @readkey = readkey($s)){
      printf "%s ", join ', ', translate(\@readkey);
      last if $readkey[0] == 0x03;
   }
}

END {
    system "stty icanon echo isig";
}

sub readkey {
   my $s = shift; 
   my $charbuff;
   my @readkey;
   eval {
      while($s->can_read(0.01)) {
         sysread STDIN, $charbuff, 1;
         push @readkey, ord $charbuff;
         last unless $readkey[0] == 0x1B;
         last if scalar @readkey >  2 && $readkey[1] == 0x5B && ord $charbuff == 0x7E;                         ## VT seq.
         last if scalar @readkey >  2 && $readkey[1] == 0x5B && ord $charbuff > 0x40 && ord $charbuff < 0x60;  ## ANSI CTRL seq.
         last if scalar @readkey == 3 && ($readkey[1] == 0x4E || $readkey[1] == 0x4F);                         ## SS2/SS3
      }
      return @readkey;
   };
}

sub translate {
   my $akey    = shift;
   my $keycode = join '', map {sprintf "%02x", $_} @{$akey};
#   my $key     = $akey->[0] == 0x7f ? 'DELETE' : join '', map {$_ < 0x20 ? '^'.chr(0x40 + $_) : chr $_} @{$akey};
#   my $tkey = $key;
   my $meta = '';
#   my ($comment, $meta) = ('', '');
   my %metamap = (1 => 'SHIFT', 2 => 'ALT', 4 => 'CTRL');
   #   my %keymap = (
   #   ## CSI (Control Sequence Introducer -> "^[[") mapping for ascii ##
   #   '^[[A' => 'CURSOR UP (CUU)', '^[[B' => 'CURSOR DOWN (CUD)', '^[[C' => 'CURSOR FORWARD/LEFT (CUF)', '^[[D' => 'CURSOR BACK/RIGHT (CUB)',
   #   '^[[F' => 'END', '^[[E' => 'KEYPAD 5', '^[[H' => 'HOME',
   #   ## Terminal sequance (vt)
   #   '^[[1~' => 'HOME', '^[[2~' => 'INSERT', '^[[3~' => 'DELETE', '^[[4~' => 'END', '^[[5~' => 'PG UP', '^[[6~' => 'PG DN', '^[[7~' => 'HOME', 
   #   '^[[8~' => 'END', '^[[10~' => 'F0', '^[[11~' => 'F1', '^[[12~' => 'F2', '^[[13~' => 'F3', '^[[14~' => 'F4', '^[[15~' => 'F5',
   #   '^[[17~' => 'F6', '^[[18~' => 'F7', '^[[19~' => 'F8', '^[[20~' => 'F9', '^[[21~' => 'F10', '^[[23~' => 'F11', '^[[24~' => 'F12', 
   #   ## SINGLE SHIFT 3 (G3 CHAR SET)
   #   '^[OP' => 'F1', '^[OQ' => 'F2', '^[OR' => 'F3', '^[OS' => 'F4' 
   #);
   
   return $akey->[0] if scalar @$akey < 2;
   if ($akey->[0] == 0x1B) { 
         if (scalar @$akey > 5 && $akey->[scalar @$akey - 3] == 0x3B){  ## META CHARACTERS
            for my $vv (sort keys %metamap) { $meta .= $metamap{$vv}." " if ($akey->[scalar @$akey - 2] - 1) & $vv }
            if($akey->[scalar @$akey - 1] == 0x7E){
               splice @$akey, scalar @$akey - 3, 2;
            } else {
               splice @$akey, scalar @$akey - 4, 3;
               $akey->[1] = 0x4F;
            }
#            $tkey = join '', map {$_ < 0x20 ? '^'.chr(0x40 + $_) : chr $_} @{$akey};
#            print $tkey."\n";
         }
	 #$comment .= " ++ \033[33mMETA KEYS: [". $meta ."]\033[0m"                  if $meta; 
	 #$comment .= " -> \033[32m CSI CODE [" . $keymap{$tkey} . "]\033[0m"        if exists $keymap{$tkey} && scalar @$akey == 3 && $akey->[1] == 0x5B;
	 #$comment .= " -> \033[32m SS3 G3 CHAR-SET [" . $keymap{$tkey} . "]\033[0m" if exists $keymap{$tkey} && scalar @$akey == 3 && $akey->[1] == 0x4F;
	 #$comment .= " -> \033[32m SS2 G2 CHAR-SET [" . $keymap{$tkey} . "]\033[0m" if exists $keymap{$tkey} && scalar @$akey == 3 && $akey->[1] == 0x4E;
	 #$comment .= " -> \033[32m VT SEQUENCE [" . $keymap{$tkey} . "]\033[0m"     if exists $keymap{$tkey} && scalar @$akey >= 4 && $akey->[scalar @$akey - 1] == 0x7E;
   } else { return 0 }
   return [0, 0];
}
