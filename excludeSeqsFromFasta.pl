#!/cvmfs/soft.computecanada.ca/easybuild/software/2017/Core/perl/5.22.4/bin/perl
system("module load bioperl/1.7.5");


use strict;
use Bio::SeqIO;

if ($#ARGV != 2) {
    print "USAGE: getSeqsFromFasta [id file] [fasta file] [output file]\n";
    print "id file: File containing list of ids to be retrieve from fasta file. One ID per line.\n";
    print "fasta file: Fasta file containing all sequences.\n";
    print "output file: Name of output file.\n";
    exit;
}

$| = 1; # turn off print buffer

# read id file 
my $idFile = shift @ARGV;
my %ids;
open (ID, $idFile) || die "Cannot open contig file\n";
foreach my $id (<ID>) {
    chomp $id;
    $ids{$id} = 1;
}
close (ID);

# read fasta file
my $fastaFile = shift @ARGV;
my $seqFile = new Bio::SeqIO (-file => $fastaFile,
                              -format => 'fasta');

my $outFile = shift @ARGV;
chomp $outFile;
open (OUT, ">$outFile") || die "Cannot open output file\n";

# loop through fasta file once and pull out sequences with match in hash
while (my $seq = $seqFile->next_seq) {
    my $id = $seq->primary_id;
    if (defined $ids{$id}) {
	} else {
        print OUT ">", $id, " ", $seq->desc, "\n";
        print OUT $seq->seq, "\n";
    }
}

close (OUT);
close (FASTA);

exit;
