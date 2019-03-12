#!/usr/bin/perl 
# Filename: usc_regression.pl
# Author: SingularityKChen
# Date: 2019.03.01
# Edition: V1.2
use strict; 
use Getopt::Long;

my ($filename, $test_group);

GetOptions (
            'filename|f=s'    =>\$filename,
            'testgroup|t=s'
            );

my $filefolder_name = "";
my $tree_attain_dir = "";


my $usc_regression_result= system("/bin/tcsh -c ''");

if ($usc_regression_result == 0) {
	print "usc regression successful".$usc_regression_result."\n";
} else {
	print "usc regression fault".$usc_regression_result."\n";
}

#my $check_result= system("/bin/tcsh -c 'cd $tree_attain_dir && gcp $filefolder_name && cd $AQARCH/bench/sh_universal_storage && grep "DATA CHECKING ERROR" sim/*/simulation.log'");