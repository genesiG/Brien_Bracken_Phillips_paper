#!/usr/bin/perl

use warnings;
use strict;
use config;

# If no trimming was performed
my $trimdir = $DATADIR;

# If trimming was performed
#my $trimdir = $TRIMDIR;

my %mapping = %SAMPLES_CTL;

foreach my $k (keys %mapping){
	run($k);
}


sub run{
	my ($f) = @_;	
	my $data_id = $f;
	my $work_dir = $ALIGNDIR;
	my $job_name = "$data_id.align";	

  # Single-end input file
	my $in_file = "$trimdir/$data_id.fastq.gz";

  # Paired-end input files
  my $in_1 = "$trimdir/$data_id.fastq.gz";
  my $in_2 = "$trimdir/$mapping{$data_id}.fastq.gz";

	
  # Output files
	my $output_prefix = "$work_dir/$data_id";	
	my $output_sam = $output_prefix.".sam";

	my $output_bam = $output_prefix.".bam";
	my $output_bam_stat1 = $output_prefix.".flagstat.txt";
	my $output_bam_stat2 = $output_prefix.".idxstat.txt";

	my $output_bam_rmdup = $output_prefix.".qc.sort.rmdup.bam";
	
	my $log_dir = "$work_dir/log";	
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
#BSUB -n 8,24
#BSUB -M 64000

conda init bash

## align using HISAT2 (output sam file)
hisat2 -p \$LSB_DJOB_NUMPROC -q --no-discordant --no-mixed -x $GNM_IDX -1 $in_1 -2 $in_2 -S $output_sam

## convert sam files to bam files, filtering out QMap<=30 or nonprimary reads, then sort and index 
samtools view -h -q 30 -b -S -f 2 -F 4 -F 8 -F 256 -F 512 -F 2048 $output_sam > $output_bam
samtools sort $output_bam -o $output_bam.tmp
mv $output_bam.tmp $output_bam
samtools index $output_bam
samtools flagstat $output_bam > $output_bam_stat1
samtools idxstats $output_bam > $output_bam_stat2

rm $output_sam 
";		

	open(OUT, ">$batchFile");
	print OUT $batch_cmd;
	close OUT;

	print("bsub  < $batchFile\n");
	system("bsub < $batchFile");	

	sleep(1);
}
