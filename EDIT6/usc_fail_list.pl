#! /usr/bin/perl 
# Filename: usc_fail_list.pl
# Author: SingularityKChen
# Date: 2019.03.28
# Edition: V4.2
#************************#
#******** NEW ***********#  
#** Version: V4.2 
#** Date: 2019.03.28
#* *Rename @tline to @tlines;
#* *Use grep to find the right case name in @tlines;
#
#** Version: V4.1 
#** Date: 2019.03.28
#* *Replace @temp_exist_case to %temp_exist_case
#   with case name and fail or pass or unknown;
#* *This script works in *** and ***;
#* *standardize the information printed onto the screen;
#* *Add die to kill the process if can't open the file;
#* *Print the usc simulation information in the end;
#* *Standardize the open function;
#* *Correct the split function;
#* *Add Term::ANSIColor to colorful the output;
#
#** Version: V3.2 
#** Date: 2019.03.28
#* *Fix the bug that can't run for *** ***;
#
#** Version: V3.1  
#** Date: 2019.03.27
#* *Add the chip_readinfo and host_user function
#   to get information and use chdir to run this
#   script at any dir.
#************************#
use strict; 
use warnings;
use Getopt::Long;
use Switch;
use POSIX;
use POSIX qw(strftime);
use Term::ANSIColor;
unshift (@INC, "***");
require("host_user.pl");
require("chip_readinfo.pl");
my ($usc_test_group, $branch, $filename);
GetOptions (
            'testgroup|t=s'    =>\$usc_test_group,
            'filename|f=s'    =>\$filename,
            );
my ($user_ref, $runsrv_ref, $user, $runsrv);
($user_ref, $runsrv_ref) = host_user();
$user = $$user_ref;
$runsrv = $$runsrv_ref;
my ($tadb_ref, $module_test_group_ref, %tadb, %module_test_group);
($tadb_ref, $module_test_group_ref) = chip_readinfo($filename);
%tadb = %$tadb_ref;
$branch = $tadb{'branch'};

my $filefolder_name = $user."_".$filename;
my $tree_attain_dir = "***";
my $usc_check_dir = "***";
chdir($usc_check_dir);
my @files = glob "sim/*/simulation.log";
my (%cases_pfu, @temp_total_cases, @fail_case, @errorcases, $datestring);
$datestring = strftime "%Y_%m_%d__%H_%M", localtime;
open(TOTAL, "<", "$usc_test_group") || die "[*E*R*R*O*R*] Can't open $usc_test_group at $usc_check_dir $!\nThe time is $datestring\n";
my @lines = <TOTAL>;
foreach my $temp_total_case (@lines){
    chomp($temp_total_case);
    $temp_total_case =~ s/(^\s+|\s+$)//g;
    my @tlines = split(/\s+/,$temp_total_case);
    foreach my $tline (@tlines){
        if ( grep(/test_/, $tline) ) { #if this concludes "test_" then
            $cases_pfu{$tline} = "unknown";#initially value every cases
            print ".";
        }
    }
}
close TOTAL;
my @total_cases = keys %cases_pfu;

foreach my $my_log (@files){
    $datestring = strftime "%Y_%m_%d__%H_%M", localtime;
    open (LOG, "<", "$my_log")  || die "[*E*R*R*O*R*] Can't open $my_log at $usc_check_dir $!\nThe time is $datestring\n";
    my $if_passed = grep /DATA COMPARE PASS/, <LOG>;
    my $if_failed = grep /DATA CHECKING ERROR/, <LOG>;
    my @temp_exit_case = split("\/",$my_log);
    if ( $if_passed and exists($cases_pfu{$temp_exit_case[1]}) ) {
        $cases_pfu{$temp_exit_case[1]} = "pass";
    } elsif ( $if_failed and exists($cases_pfu{$temp_exit_case[1]}) ) {
        $cases_pfu{$temp_exit_case[1]} = "fail";
        push(@fail_case, $temp_exit_case[1]);
        print color 'bold on_white red';
        print "\n--------------\n[*E*R*R*O*R*] $temp_exit_case[1] failed\n--------------\n";
        print color 'reset';
    } elsif (exists($cases_pfu{$temp_exit_case[1]}) ){
        #print "--------------\n[*I*N*F*O*] $temp_exit_case[1] hasn't run yet\n--------------\n";
    } else {
        push(@errorcases, $temp_exit_case[1]);
        print color 'bold on_black red';
        print "\n--------------\n[*E*R*R*O*R*] $temp_exit_case[1] doesn't exists in \%cases_pfu at line 89\n--------------\n";
        print color 'reset';
    }
    close (LOG);
}

open(FAIL, ">", "fail.list") || die "[*E*R*R*O*R*] Can't open fail.list at $usc_check_dir $!\nThe time is $datestring\n";
print FAIL @fail_case;
close(FAIL);
my $passednum = '0';
my $failednum = '0';
my $unknownum = '0';
my $size = @total_cases;
foreach my $cleanedcase (@total_cases){
    my $case_pfu = $cases_pfu{$cleanedcase};
    switch($case_pfu){
        case "pass"     {
            $passednum ++;
        }
        case "fail"     {
            $failednum ++;
        }
        case "unknown"  {
            $unknownum ++;
        }
        else            {
            print color 'bold on_black red';
            print "\n--------------\n[*E*R*R*O*R*] one error at line 116\n--------------\n";
            print color 'reset';
        }
    }
}
my $fail_ratio = POSIX::ceil($failednum/$size*100);
my $finishednum = $passednum + $failednum;
my $finish_ratio = sprintf "%.0f",$finishednum/$size*100;
my $errornum = @errorcases;
print "\n--------------\n[*I*N*F*O*] usc check finished\nthere are $errornum \@errorcases\n";
print "the fail list is\n$usc_check_dir/fail.list\n--------------\n\n\n";
print "usc\t$usc_test_group\t$failednum\t$passednum\t$finishednum\t$size\t$fail_ratio\%\t$finish_ratio\%\t\n";
