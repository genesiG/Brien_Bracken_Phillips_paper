#/usr/bin/perl

package config; 

use strict;
use warnings;

use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw(
	$Project_Name $SPECIES $ALIGNER $WORKDIR $CODEDIR
        $DATADIR $QCDIR1 $TRIMDIR $ALIGNDIR $BEDDIR $COUNTDIR $RSEQCDIR $DESEQ2DIR
	$GNM_IDX $GNM_GTF $GNM_BED12 $GNM_SIZES $BLACKLIST
	%SAMPLES %SAMPLES_CTL);

##### change for each projet ########################################
our $Project_Name = "RNA";
our $SPECIES = "hg38";
our $ALIGNER = "HISAT2";

##### set up work directory #########################################
our $WORKDIR = "/home/genesi/RNAseq_2024_Brien_Paper";
our $CODEDIR = "/home/genesi/RNAseq_2024_Brien_Paper/pipelines";

our $DATADIR = $WORKDIR."/Original Data and Metadata/Original Data/raw_data";
our $QCDIR1 = $WORKDIR."/fastqc1"; 
our $TRIMDIR = $WORKDIR."/trim";
our $ALIGNDIR = $WORKDIR."/alignment";
our $BEDDIR = $WORKDIR."/bed";
our $COUNTDIR = $WORKDIR."/featureCounts";
our $RSEQCDIR = $WORKDIR."/rseqc";
our $DESEQ2DIR = $WORKDIR."/DESeq2";

##### set up reference genome #######################################
our $GNM_IDX = "/home/genesi/mylibrary/HISAT2/hg38/GCA_000001405.15_GRCh38_full_analysis_set"; # basenae of genome indexes files for the aligner 
our $GNM_GTF = "/home/genesi/mylibrary/Genomes/hg38/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation.gtf";
our $GNM_BED12 = "/home/genesi/mylibrary/$SPECIES\_refseq.bed12";
our $GNM_SIZES = "/home/genesi/mylibrary/chr_size/$SPECIES.chrom.sizes";
our $BLACKLIST = "/home/genesi/mylibrary/blacklist/$SPECIES.blacklist.bed";

##### read in sample files from sample_list.txt #####################
our %SAMPLES; #hash keys are sample names, hash values are *.fastq files
our %SAMPLES_CTL; #hash keys are sample names, hash values are the corresponding input control sample names
open(IN, "/home/genesi/RNAseq_2024_Brien_Paper/paired_samples.txt") or die "can not open sample list files\n";
my $line = <IN>; #skip header line
while(my $line = <IN>){
	chomp $line;
	my @t = split('\t', $line);
	$SAMPLES{$t[0]} = "$DATADIR/$t[0].fastq.gz";
	if ($t[1] ne "-"){
		$SAMPLES_CTL{$t[0]} = $t[1];
	}
}
close IN;

1;