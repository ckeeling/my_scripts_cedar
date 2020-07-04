#!/usr/bin/perl -w
use strict;

if (scalar(@ARGV) != 1) {
    print "Retrieve sequences of length less than user given value\n";
    print "*** NOTE: Sequence cannot be wrapped\n";
    print "USAGE: cat fasta | filterSeqBySize.pl [length sequence cutoff]\n";
    exit;
}

$| = 1;

my $size = shift @ARGV;
chomp $size;

while (my $line = <STDIN>) {
    if ($line =~ /\>/) {
        my $seq = <STDIN>;
        chomp $seq;

        if (length($seq) < $size) {
            print $line;
            print "$seq\n";
        }
    }
}
