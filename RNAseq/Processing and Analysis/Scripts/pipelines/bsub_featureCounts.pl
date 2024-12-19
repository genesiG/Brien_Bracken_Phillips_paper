#/usr/bin/perl

use strict;
use warnings;
use config;

foreach my $k (keys %SAMPLES){
	run($k);
}

sub run{
	my ($f) = @_;	
	my $data_id = $f;
	my $work_dir = $COUNTDIR;
  my $log_dir = "$work_dir/log";
	my $job_name = "$data_id.count";	

	my $in_file = "$ALIGNDIR/$data_id.bam";;

	my $logOutFile = "$log_dir/$data_id.out";
	my $logErrFile = "$log_dir/$data_id.error";
	my $batchFile = "$log_dir/$data_id.batch";

	if(! -d $work_dir){
		system("mkdir $work_dir");
	}
	if(! -d $log_dir){
		system("mkdir $log_dir");
	}

	my $batch_cmd="
#!/bin/bash
#BSUB -P $Project_Name
#BSUB -J $job_name
#BSUB -o $logOutFile
#BSUB -e $logErrFile
#BSUB -q normal
#BSUB -M 61440

conda init bash

# -p specifies paired-end data   
# --countReadPairs (paired-end data) count read pairs instead of reads
# -B require that BOTH read pairs be aligned 
# -C do NOT count read pairs with ends mapping to different chromosomes/strands
# -M count multimapped reads (that aligned to more than one site)
# --primary If a read was aligned to more than one place (multimapping), count ONLY the primary alignment
# -O count multi-overlaping reads (that overlap more than one feature, NOT RECOMMENDED for RNAseq)
# -s 0 (default) ignores strandness / 1 strand-specific summarization
# -t Feature used for read counting (exon by default)
# -g Specify attribute type in GTF annotation ('gene_id' by default)
featureCounts -p -B -C -M --primary -s 1 -t gene -g gene_id -a $GNM_GTF -o $work_dir/$data_id.featureCounts.txt $in_file

# Get only columns 1 (gene_id), 5 (strand) and 6 (gene_length) 
tail -n+3 $work_dir/$data_id.featureCounts.txt | cut -f1,5,6 > $work_dir/gene_length.txt

# Get only columns 1 (gene_id) and 7 (read counts)
tail -n+3 $work_dir/$data_id.featureCounts.txt | cut -f1,7 > $work_dir/$data_id.counts.txt.tmp
mv $work_dir/$data_id.counts.txt.tmp $work_dir/$data_id.counts.txt

";
	open(OUT, ">$batchFile");
	print OUT $batch_cmd;
	close OUT;

	print("bsub  < $batchFile\n");
	system("bsub < $batchFile");	

	sleep(1);
}

