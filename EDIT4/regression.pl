#!/usr/bin/perl 
# Filename: regression.pl
# Author: SingularityKChen
# Date: 2019.03.04
# Edition: V4.4
use strict; 
use Getopt::Long;
#************************#
#***** NEED REPLACE *****#
#************************#
#=opt
my $filename=''; # title of email
my $module='';
my $test_group='';
my $run_case_number='3'; #license
#my $if_regression=0; #!!!!! need input it when run regression.sh alone
#************************#
#********* OVER *********#
#************************#
#=cut
#*********
#***use these by delete '#' before '=cut' & '=opt' ***#
=pot
my ($filename, $moudle, $test_group, $run_case_number);

GetOptions (
            'filename|f=s'    =>\$filename,
            'module|m=s'    =>\$module,
            'test_group|t=s'    =>\$test_group,
            'run_case_number|r=s'    =>\$run_case_number,
            );
=cut

my $tree_attain_dir="";
my $filefolder_name="";
my $regression_dir="";
my $regression_result = system("/bin/tcsh -c ''");

if ($regression_result == 0) {
	print $module."regression successful".$regression_result."\n";
} else {
	print $module."regression fault".$regression_result."\n";
}
