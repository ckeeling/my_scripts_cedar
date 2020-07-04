#!/usr/bin/perl -w
use strict;

# USAGE: "cat fasta | getLength.pl"
# Only use unwrapped fasta file

my $max = -1;
my $nnmax = -1;
my $maxSeq = "";
my $nnmaxSeq = "";

my $numSeq = 0;
my $sum = 0;
my $nnsum = 0;
my @lengths;
my @nnlengths;

while (my $line = <STDIN>) {

    if ($line =~ /\>/) {
        chomp $line;
	$line = substr $line, 1;
        my $nxtLine = <STDIN>;
        chomp $nxtLine;

        my $len = length($nxtLine);
	print "$line\t$len\n"

    }
}

