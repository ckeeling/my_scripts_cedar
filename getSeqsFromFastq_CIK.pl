#!/usr/bin/perl
use strict;
use warnings;

my $idfile = shift @ARGV;
my $fastq = shift @ARGV;

my %ids;
open (ID, $idfile) || die;
foreach my $line (<ID>) {
    chomp $line;
    $ids{$line} = 1;
}
close (ID);

###

open (FASTQ, $fastq) || die;
$| = 1;
while (my $line = <FASTQ>) {
    if ($line  =~ /^\@(\S*)/) {
        if (defined $ids{$1}) {
            print $line;
            for my $i (1 .. 3) {
                my $nxtline = <FASTQ>;
                print $nxtline;
            }
        }
    }
}
close (FASTQ);
