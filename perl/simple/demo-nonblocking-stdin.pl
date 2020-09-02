#!/usr/bin/perl
use warnings;
use strict;
use IO::Select;
use Data::Dumper;

## Script to demonstrate nonblocking STDIN
## Unfortunately I don't have all keycode mapped to ANSI escape codes :(
## Mzvk 2020

my $s = IO::Select->new();
$s->add( \*STDIN );

system "stty -icanon -isig -echo time 0 min 1";
print "Non-blocking STDIN demo. Press ^C to terminate.\n";
while (1) {
   if(my @readkey = readkey($s)){
      translate(\@readkey);
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
         last if scalar @readkey == 3 && $readkey[1] == 0x5B && $readkey[2] > 0x40;
         last if scalar @readkey > 2 && $readkey[1] == 0x5B && ord $charbuff == 0x7E;
         last if scalar @readkey == 6 && $readkey[1] == 0x5B && $readkey[3] == 0x3B;
      }
      return @readkey;
   };
}

sub translate {
   my $akey    = shift;
   my $keycode = join '', map {sprintf "%02x", $_} @{$akey};
   my $key     = $akey->[0] == 0x7f ? 'DELETE' : join '', map {$_ < 0x20 ? '^'.chr(0x40 + $_) : chr $_} @{$akey};
   my $tkey = $key;
   my ($comment, $meta) = ('', '');
   my %metamap = (1 => 'SHIFT', 2 => 'ALT', 4 => 'CTRL');
   my %keymap = (
      ## C0/C1 Control Codes mapping for ASCII ##
      '^A' => 'START OF HEADING (SOH)', '^B' => 'START OF TEXT (STX)', '^C' => 'END OF TEXT (ETX)', '^D' => 'END OF TRANSMISSION (EOT)', '^E' => 'ENQUIRY (ENQ)', 
      '^F' => 'ACKNOWLEDGE (ACK)', '^G' => 'BELL (BEL)', '^H' => 'BACKSPACE (BS)', '^I' => 'HORIZONTAL TAB (HT)', '^J' => 'LINE FEED (LF)', 
      '^K' => 'VERTICAL TAB (VT)', '^L' => 'FORM FEED (FF)', '^M' => 'CARRIAGE RETURN (CR)', '^N' => 'SHIFT OUT (SO)', '^O' => 'SHIFT IN (SI)', 
      '^P' => 'DATA LINK ESCAPE (DLE)', '^Q' => 'DEVICE CTRL 1 -- XON (DC1)', '^R' => 'DEVICE CTRL 2 (DC2)', '^S' => 'DEVICE CTRL 3 -- XOFF (DC3)', 
      '^T' => 'DEVICE CTRL 4 (DC4)', '^U' => 'NEGATIVE ACKNOWLEDGE (NAK)', '^V' => 'SYNCHRONOUS IDLE (SYN)', '^W' => ' END OF TRANSMISSION BLOCK (ETB)', 
      '^X' => 'CANCEL (CAN)', '^Y' => 'END OF MEDIUM (EM)', '^Z' => 'SUBSTITUTE (SUB) -- EOF', '^[' => 'ESCAPE (ESC)', '^\\' => 'FILE SEPARATOR',
      '^]' => 'GROUP SEPERATOR (GS)', '^^' => 'RECORD SEPARATOR (RS)', '^_' => 'UNIT SEPARATOR (US)', '^?' => 'DELETE (DEL)', ' ' => 'SPACE (SP)',
      ## CSI (Control Sequence Introducer -> "^[[") mapping for ascii ##
      '^[[A' => 'CURSOR UP (CUU)', '^[[B' => 'CURSOR DOWN (CUD)', '^[[C' => 'CURSOR FORWARD/LEFT (CUF)', '^[[D' => 'CURSOR BACK/RIGHT (CUB)',
      '^[[F' => 'END', '^[[E' => 'KEYPAD 5', '^[[H' => 'HOME',
      ## Terminal sequance (vt)
      '^[[1~' => 'HOME', '^[[2~' => 'INSERT', '^[[3~' => 'DELETE', '^[[4~' => 'END', '^[[5~' => 'PG UP', '^[[6~' => 'PG DN', '^[[7~' => 'HOME', 
      '^[[8~' => 'END', '^[[10~' => 'F0', '^[[11~' => 'F1', '^[[12~' => 'F2', '^[[13~' => 'F3', '^[[14~' => 'F4', '^[[15~' => 'F5',
      '^[[17~' => 'F6', '^[[18~' => 'F7', '^[[19~' => 'F8', '^[[20~' => 'F9', '^[[21~' => 'F10', '^[[23~' => 'F11', '^[[24~' => 'F12', 
      ## SINGLE SHIFT 3 (G3 CHAR SET)
      '^[OP' => 'F1', '^[OQ' => 'F2', '^[OR' => 'F3', '^[OS' => 'F4' 
   );
   if (scalar @$akey < 2) { $comment = " -> \033[32m CONTROL CODE [" . $keymap{$key} . "]\033[0m" if exists $keymap{$key};
   } else {
      if ($akey->[0] != 0x1B) { $key = '! SCRAMBLED/UNKNOWN KEYCODE !'
      } else {
         if (scalar @$akey > 5 && $akey->[scalar @$akey - 3] == 0x3B){  ## META CHARACTERS
            for my $vv (sort keys %metamap) { $meta .= $metamap{$vv}." " if ($akey->[scalar @$akey - 2] - 1) & $vv }
            if($akey->[scalar @$akey - 1] == 0x7E){
               splice @$akey, scalar @$akey - 3, 2;
            } else {
               splice @$akey, scalar @$akey - 4, 3;
            }
            $tkey = join '', map {$_ < 0x20 ? '^'.chr(0x40 + $_) : chr $_} @{$akey};
         }
         $comment .= " ++ \033[33mMETA KEYS: [". $meta ."]\033[0m"                  if $meta; 
         $comment .= " -> \033[32m CSI CODE [" . $keymap{$tkey} . "]\033[0m"        if exists $keymap{$tkey} && scalar @$akey == 3 && $akey->[1] == 0x5B;
         $comment .= " -> \033[32m SS3 G3 CHAR-SET [" . $keymap{$tkey} . "]\033[0m" if exists $keymap{$tkey} && scalar @$akey == 3 && $akey->[1] == 0x4F;
         $comment .= " -> \033[32m SS2 G2 CHAR-SET [" . $keymap{$tkey} . "]\033[0m" if exists $keymap{$tkey} && scalar @$akey == 3 && $akey->[1] == 0x4E;
         $comment .= " -> \033[32m VT SEQUENCE [" . $keymap{$tkey} . "]\033[0m"     if exists $keymap{$tkey} && scalar @$akey >= 4 && $akey->[scalar @$akey - 1] == 0x7E;
      }
   }
   printf "KEY PRESSED: \033[94m[0x%-14s]\033[0m %-8s %s\n", $keycode, $key, $comment;
}
