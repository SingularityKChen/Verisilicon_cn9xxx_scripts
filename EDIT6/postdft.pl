#!/usr/bin/perl 
# Filename: postdft.pl
# Author: SingularityKChen
# Date: 2019.03.15
# Edition: V1.0
# Servise: srv200
# FOR the VIP chip only because of the env
# After the pre-source of spyglass, then you can run this. 
#************************#
#******** NEW ***********#  
#** Version: V1.0
#* *Do something
#************************#
use strict; 
use Getopt::Long; 
use warnings;
my $run_dir;
GetOptions (
            'rundir|r=s'      => \$run_dir,
                        );
chdir($run_dir);
my $cp_sdcsgcd_dir = "";
my $sdcsgdc_filename = glob "$cp_sdcsgcd_dir/abcdefg.*";
print $sdcsgdc_filename;
open(DFTSGDC, ">", "dft.sgdc") || die "[*E*R*R*O*R*] Can't open dft.sdc at $run_dir $!\n";
open(DFTHEAD, "<", "dft_head") || die "[*E*R*R*O*R*] Can't open dft_head at $run_dir $!\n";
while (<DFTHEAD>) {
	chomp;
	print DFTSGDC $_;
	print DFTSGDC "\n";
}
close(DFTHEAD);
open(SDCSGDC, "<", $sdcsgdc_filename) || die "[*E*R*R*O*R*] Can't open sdc2sgdc.sgdc.* at $run_dir $!\n";
while (<SDCSGDC>) {
	chomp;
	if (/current_design/) {
		# body...
	}else {
		print DFTSGDC $_;
		print DFTSGDC "\n";
	}
}
close(SDCSGDC);
close(DFTSGDC);
my $sourcecode = "";
print $sourcecode;
my $postdft_result = system "/bin/tcsh -c 'gnome-terminal --title=\"postdft\" -x tcsh -c \"$sourcecode;exec tcsh\" '";