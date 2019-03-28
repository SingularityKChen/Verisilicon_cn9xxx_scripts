#!/usr/bin/perl 
# Filename: postdft.pl
# Author: SingularityKChen
# Date: 2019.03.19
# Edition: V1.2
# Servise: 
# FOR the *** only because of the env
# After the pre-source of spyglass, then you can run this. 
#************************#
#******** NEW ***********#  
#** Version: V1.2
#** Date: 2019.03.19
#* *Add the test-clock after the clock signal;
#
#** Version: V1.0
#** Date: 2019.03.15
#* *Try to finish the second dft automaticly;
#************************#
use strict; 
use Getopt::Long; 
use warnings;
my $run_dir;
GetOptions (
            'rundir|r=s'      => \$run_dir,
                        );
chdir($run_dir);
my $read_sdcsgcd_dir = $run_dir."***";
my $sdcsgdc_filename = glob "$read_sdcsgcd_dir/sdc2sgdc.sgdc.*";
#print $sdcsgdc_filename;
open(DFTSGDC, ">", "./sg_setup/dft.sgdc") || die "--------------\n[*E*R*R*O*R*] Can't open dft.sgdc at $run_dir/sg_setup $!\n--------------\n";
open(DFTHEAD, "<", "./sg_setup/dft_head") || die "--------------\n[*E*R*R*O*R*] Can't open dft_head at $run_dir/sg_setup $!\n--------------\n";
while (<DFTHEAD>) {
	chomp;
	print DFTSGDC $_;
	print DFTSGDC "\n";
}
close(DFTHEAD);
open(SDCSGDC, "<", $sdcsgdc_filename) || die "--------------\n[*E*R*R*O*R*] Can't open sdc2sgdc.sgdc.* at $read_sdcsgcd_dir $!\n--------------\n";
while (<SDCSGDC>) {
	chomp;
	if (/current_design/) {
		# body...
	} elsif (/^clock  -name "\w+".*$/) {
		print DFTSGDC $_;
		print DFTSGDC " -testclock";
		print DFTSGDC "\n";
	} else {
		print DFTSGDC $_;
		print DFTSGDC "\n";
	}
}
close(SDCSGDC);
close(DFTSGDC);
my $sourcecode = "cd $run_dir && source source_me_to_run_sg_dft | tee postdft_log";
my $postdft_result = system "/bin/tcsh -c 'gnome-terminal --title=\"postdft\" -x tcsh -c \"$sourcecode;exec tcsh\" '";
