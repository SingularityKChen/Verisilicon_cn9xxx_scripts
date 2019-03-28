#!/usr/bin/perl
# Filename: regression.pl
# Author: SingularityKChen
# Date: 2019.03.27
# Edition: V6.3
#************************#
#******** NEW ***********#  
#** Version: V6.3 
#** Date: 2019.03.27
#* *Can run usc now
#
#** Version: V6.2  
#* *Add switch to specialize the 
#   $run_case_number for each module.
#* *Adjust some dir to fit the *** module
#
#** Version: V6.1
#* *Fix the bug that the $datestring
#   equals to the starting time;
#* *Add runlog of testgroup;
#* *Better the way to see if the results 
#   is successful rather than being closed;
#
#** Version: V6.0
#* *Add the strftime module to 
#   better the control of regression;
#
#** Version: V5.3.1
#* *Fix the bug of "can not 
#   create directory '/local/Run128'";
#* *Fix the bug of child process 
#   is one more than $max_module_size;
#
#** Version: V5.3
#* *Replace the dir with $user and $runsrv;
#************************#
use strict; 
use Getopt::Long;
use warnings;
use POSIX ":sys_wait_h";
use POSIX qw(strftime);
use Switch;
unshift (@INC, "***");
require("chip_readinfo.pl");
require("host_user.pl");
#************************#
#***** NEED REPLACE *****#
#************************#
#=opt
my $run_case_number;
my $run_case_number_default = '4'; #license,default
my $max_module_size = '6';
my ($filename, $module, $test_group);

GetOptions (
            'filename|f=s'    =>\$filename,
            'max_module_size|m=s'    =>\$max_module_size,
            'run_case_number_default|r=s'    =>\$run_case_number_default,
            );

my ($tadb_ref, $module_test_group_ref, %tadb, %module_test_group);
($tadb_ref, $module_test_group_ref) = chip_readinfo($filename);
%module_test_group = %$module_test_group_ref;

my ($user_ref, $runsrv_ref, $user, $runsrv);
($user_ref, $runsrv_ref) = host_user();
$user = $$user_ref;
$runsrv = $$runsrv_ref;

my $datestring;

my @test_groups = keys %module_test_group;
my $test_group_size = @test_groups;
my $tree_attain_dir = "**";
my $filefolder_name = $user."_".$filename;
my $regression_log_dir = "***";
chdir($regression_log_dir);
if (-e $regression_log_dir) {
    print "$regression_log_dir exists!\n";
} else {
    system("mkdir -p $regression_log_dir");
}
#my %child_pid;#record the pid of child process
my $num_proc = 0;#number of proc
my $num_collect = 0;#number of collected
my $collect;#signal of collect
 
$SIG{CHLD} = sub { $num_proc-- };#get the child signal
for (my $i = 0; $i < $test_group_size; $i ++) {
    my $pid = fork();#fork a new process
    if (!defined($pid)) {
        $datestring = strftime "%Y_%m_%d__%H_%M", localtime;
        print "--------------\n[*E*R*R*O*R*] Error in fork: $!\nThe time is $datestring\n--------------\n";
        exit 1;
    }
    if ($pid == 0) {
 
        ## == child proc ==
        $test_group = $test_groups[$i];
        $module = $module_test_group{$test_group};
        $datestring = strftime "%Y_%m_%d__%H_%M", localtime;
        print "[*I*N*F*O*] Child $i : My pid = $$\n$test_group STARTED\nThe time is $datestring\n";
        #$child_pid{$$} = $test_group;
        if ($module eq 'usc' || $module eq 'USC') {
            my $regression_result = system("/bin/tcsh -c 'gnome-terminal --title=\"regression $filename $module\" -x tcsh -c \"runusc -f $filename -l $regression_log_dir -t $test_group; exec tcsh\" '");
        } else {
            my $regression_dir = "***";
            switch($module){
                case "***" { $run_case_number = '2' }
                case "***" { $run_case_number = '2' }
		#***
                else { $run_case_number = $run_case_number_default }
            }
            my $long_code = "*** | tee $regression_log_dir".$module."_log";
            my $regression_result = system("/bin/tcsh -c 'gnome-terminal --title=\"regression $filename $module\" -x tcsh -c \"$long_code; mkdir -p ../successful/$module; exec tcsh\" '");
            $datestring = strftime "%Y_%m_%d__%H_%M", localtime;
            if ($regression_result == 0 && -e "$regression_dir/../successful/$module") {
                print "--------------\n[*I*N*F*O*] $module regression successful\nThe time is $datestring\n--------------\n";
                system("rm -rf $regression_dir/../successful/$module");
            } else {
                print "--------------\n[*E*R*R*O*R*] $module regression failed\nThe time is $datestring\n--------------\n";
            }
        }
        exit 0;
    }
 
    $num_proc ++;
 
    ## == if need to collect zombies ==
    if (($i-$num_proc-$num_collect) > 0) {
        while (($collect = waitpid(-1, WNOHANG)) > 0) {
            $num_collect ++;
            $datestring = strftime "%Y_%m_%d__%H_%M", localtime;
            print "--------------\n[*I*N*F*O*] Some one has FINISHED\nThe time is $datestring\n--------------\n";
        }
    }
    while ($num_proc == $max_module_size) {
        print ".";
        sleep(100);
    }
}
system("rm -rf $regression_log_dir/../successful");
exit 0;
