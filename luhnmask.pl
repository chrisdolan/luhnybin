#!perl -w
use strict;

*STDOUT->autoflush(1);

my %p;
while (my $line = <>) {
   # positions of characters that should become 'X'
   %p = ();
   # regex with side effect of marking positions. '(*FAIL)' forces backtracking to find overlapping CCs
   $line =~ m/((?:\d[\ \-]*){14,16})(?{luhn($1, pos(), \%p)})(?:$|(*FAIL))/gs;

   print xx($line, \%p);
}

# compute the luhn checksum. On success, record the positions of the digits in the $p hash
# $pos is the offset of the end of the subtring from the beginning of the line
sub luhn {
   my ($substr, $pos, $p) = @_;
   return if !defined $substr;
   $pos -= length $substr; # set back to beginning of substr
   my @n = $substr =~ m/(\d)/gs;

   # Luhn checksum
   my $c = 0;
   for (my $i=0; $i<@n; $i++) {
      my $d = $n[$i];
      if (($i % 2) == (@n % 2)) {
         $d *= 2;
      }
      if ($d > 9) {
         $d -= 9;
      }
      $c += $d;
   }

   if (($c % 10) == 0) {
      for my $d ($substr =~ m/(.)/gs) {
         if ($d =~ m/\d/) {
            $p->{$pos} = 1;
         }
         ++$pos;
      }
   }
}

sub xx {
   my ($line, $p) = @_;
   my @s = $line =~ m/(.)/gs;
   for my $pos (keys %{$p}) {
      $s[$pos] = 'X';
   }
   return join '', @s;
}
