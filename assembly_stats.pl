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

        $numSeq ++;

        my $nxtLine = <STDIN>;
        chomp $nxtLine;

        my $len = length($nxtLine);
        push (@lengths, $len);
        $sum += $len;

        $nxtLine =~ s/[nN]//g;
        my $nnlen = length($nxtLine);
        push (@nnlengths, $nnlen);
        $nnsum += $nnlen;

        if ($max == -1 || $max < $len) {
            $max = $len;
            $maxSeq = $line;
        }

        if ($nnmax == -1 || $nnmax < $nnlen) {
            $nnmax = $nnlen;
            $nnmaxSeq = $line;
        }

    }
}

print "Of total $numSeq sequences:\n";
print "Total length is $sum\n";
print "Total Non-N's length is $nnsum\n";

my @sorted = reverse sort {$a <=> $b} @lengths;
my $count = 0;
my $scount =0;
while (my $slice = shift @sorted) {
$scount++;
    $count += $slice;
    if ($count > $sum/2) {
        print "N50 size is $slice with $scount sequences\n";
        last;
    }

}

@sorted = reverse sort {$a <=> $b} @lengths;
$count = 0;
$scount =0;
while (my $slice = shift @sorted) {
$count += $slice;
$scount++;
    if ($count > $sum*0.9) {
        print "N90 size is $slice with $scount sequences\n";
        last;
    }
}

@sorted = reverse sort {$a <=> $b} @lengths;
$count = 0;
$scount =0;
while (my $slice = shift @sorted) {
$count += $slice;
$scount++;
    if ($count > $sum*0.95) {
        print "N95 size is $slice with $scount sequences\n";
        last;
    }
}

@sorted = reverse sort {$a <=> $b} @lengths;
$count = 0;
$scount =0;
while (my $slice = shift @sorted) {
$count += $slice;
$scount++;
    if ($count > $sum*0.99) {
        print "N99 size is $slice with $scount sequences\n";
        last;
    }
}

my @nnsorted = reverse sort {$a <=> $b} @nnlengths;
$count = 0;
while (my $slice = shift @nnsorted) {
    $count += $slice;
    if ($count > $nnsum/2) {
        print "Non-N N50 size is $slice\n";
        last;
    }
}

print "Longest read length is $max from $maxSeq\n";
print "Longest non-N read length is $nnmax from $nnmaxSeq\n";
print "Average length is ", $sum/$numSeq, "\n";
print "Average Non-N length is ", $nnsum/$numSeq, "\n";

@sorted = reverse sort {$a <=> $b} @lengths;
open(my $fh, '>', 'assembly_stats.histo');
foreach(@sorted)
{
    print $fh "$_\r\n";
}
close $fh;
print "done\n";

@sorted = reverse sort {$a <=> $b} @lengths;
$count = 0;
$scount =0;
my $percentile=0;
open(my $fj, '>', 'assembly_stats.histo2');
while (my $slice = shift @sorted) {
$scount++;
    $count += $slice;
$percentile=$count/$sum;
        print $fj "$percentile\t$slice\t$scount\n";

}

close $fj;
