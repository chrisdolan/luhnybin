#!perl -w
use strict;

# Chris Dolan, http://chrisdolan.net/
#   See http://corner.squareup.com/2011/11/luhny-bin.html
#   and https://github.com/chrisdolan/luhnybin

# Explanation:
#   - Find all substrings of 14-16 digits in the line, possibly interleaved with ' ' or '-'
#   - For each substring, compute the Luhn checksum
#   - If the checksum is correct, replace all digits in the substring with 'X'

# needed to unblock I/O -- otherwise Perl waits for Java while Java waits for Perl
*STDOUT->autoflush(1);

my @s;
while (my $line = <>) {
   # make a copy of the string that's easy to edit
   @s = $line =~ m/(.)/gs;

   # regex with side effect of marking positions. '(*FAIL)' forces backtracking to find overlapping CCs
   # '(?{...})' is a zero-width always-succeeding assertion the executes embedded code
   $line =~ m/((?:\d[\ \-]*){14,16})(?{luhn($1, pos(), \@s)})(*FAIL)/gs;

   print join '', @s;
}

# compute the luhn checksum. On success, replace the digits in the $s copy of the string with 'X'
# $pos is the offset of the *end* of the subtring from the beginning of the line
sub luhn {
   my ($substr, $pos, $s) = @_;
   return if !defined $substr;
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
      # Success!
      for my $i ($pos - length($substr) .. $pos - 1) {
         if ($s->[$i] =~ m/\d/) {
            $s->[$i] = 'X';
         }
      }
   }
}
