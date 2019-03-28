#!/usr/bin/perl 
# Filename: usc_regression.pl
# Author: SingularityKChen
# Date: 2019.03.27
# Edition: V3.1
#************************#
#******** NEW ***********#  
#** Version: V3.1  
#** Date: 2019.03.27
#* *Use chip_readinfo function to read 
#   the testgroup.
#
#** Version: V2.2
#* *use host and user to pitch the dir
#************************#
use strict; 
use Getopt::Long;
unshift (@INC, "***");
require("host_user.pl");
require("chip_readinfo.pl");
my ($filename, $test_group, $regression_log_dir, $branch);

GetOptions (
            'filename|f=s'    =>\$filename,
            'testgroup|t=s'    =>\$test_group,
            'logdir|l=s'    =>\$regression_log_dir,
            );

my ($user_ref, $runsrv_ref, $user, $runsrv);
($user_ref, $runsrv_ref) = host_user();
$user = $$user_ref;
$runsrv = $$runsrv_ref;

my $filefolder_name = $user."_".$filename;
my $tree_attain_dir = "***";

my ($tadb_ref, $module_test_group_ref, %tadb, %module_test_group);
($tadb_ref, $module_test_group_ref) = chip_readinfo($filename);
%tadb = %$tadb_ref;
$branch = $tadb{'branch'};

my $usc_run_dir = "***";
my $usc_regression_result= system("/bin/tcsh -c '*** && mkdir -p $regression_log_dir/../successful/usc'");

if ($usc_regression_result == 0 && -e "$regression_log_dir/../successful/usc") {
	print "**************\n[*I*N*F*O*] usc regression successful\n**************\n";
	system("rm -rf $regression_log_dir/../successful/usc && checkusc -f $filename -t $test_group");
} else {
	print "**************\n[*E*R*R*O*R*] usc regression failed\n**************\n";
}
