#/usr/bin/perl


use strict;
use warnings;
use config;

my $work_dir = $COUNTDIR;

my $o_file = "$COUNTDIR/RNAseq_counts_Brien_paper.txt";
my $header_file = "$work_dir/temp.header";

my $idx = 1;
my $header = "refGene";

foreach my $data_id (sort(keys %SAMPLES)){
	$header .= "\t".$data_id;

	my $idx2 = $idx-1;
        if($idx == 1){
                system("cp $work_dir/$data_id.counts.txt $work_dir/temp.$idx");
	}else{
		system("join $work_dir/temp.$idx2 $work_dir/$data_id.counts.txt > $work_dir/temp.$idx");
        }
	$idx++;
}

open(OUT, ">$header_file");
print OUT $header,"\n";
close OUT;

my $idx3 = $idx-1;
system("cat $header_file $work_dir/temp.$idx3 > $o_file ; rm $work_dir/temp.\*");
system("sed -i \"s. .\\t.g\" $o_file");
