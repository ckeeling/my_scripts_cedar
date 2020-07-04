#!/usr/bin/perl -w
use strict;
my $firstline = 1;

$| = 1;

while (my $line = <STDIN>) {
    if ($line =~ />/) {
        $firstline? print $line : print "\n$line";

    } elsif ($line !~ />/) {
        $firstline = 0;
        $line =~ s/\n//;
        print $line; 
        
    }
}
print "\n";

