#!/usr/bin/perl
# Filename: regression.pl
# Author: SingularityKChen
# Date: 2019.04.30
# Version: V6.7
#************************#
#******** NEW ***********#
#** Version: V6.7
#** Date: 2019.04.30
#* *Remove multirun command to a new script
#   subregression.pl;
#* *Add a function check_processing() to print
#   condition dynamicly;
#* *Rewrite the out put to make it more beautiful;
#
#** Version: V6.6.2
#** Date: 2019.04.23
#* *Add $run_case_number in the title of each new terminal;
#* *Decide whether the module has run before and contirun
#   by determining whether $regression_dir/sim exists;
#* *Rename $regression_result to $run_regression;
#
#** Version: V6.6.1
#** Date: 2019.04.19
#* *Delete "exec tcsh" at the end of every regression,
#   but open the regression log;
#
#** Version: V6.5 
#** Date: 2019.04.15
#* *Add some case in the values of licenses;
#
#** Version: V6.4 
#** Date: 2019.04.01
#* *Correct the $regression_dir;
#
#** Version: V6.3 
#** Date: 2019.03.27
#* *Can run usc now;
#
#** Version: V6.2  
#* *Add switch to specialize the 
#   $run_case_number for each module;
#* *Adjust some dir to fit the sys module;
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
unshift (@INC, "");
require("chip_readinfo.pl");
require("host_user.pl");
$| = 1;
my $run_case_number;
my $run_case_number_default = '2'; #license,default
my $max_module_size = '3';
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
my $tree_attain_dir = "";
my $filefolder_name = $user."_".$filename;
my $regression_log_dir = "";
chdir($regression_log_dir);
if (-e $regression_log_dir) {
    
} else {
    system("mkdir -p $regression_log_dir");
}
my %child_pid; #record the pid of child process
my %start_time;
my $num_proc = 0; #number of proc
my $num_collect = 0; #number of collected
my $collect; #signal of collect
my @exist_proids;
$SIG{CHLD} = sub { $num_proc-- };#get the child signal
for (my $i = 0; $i < $test_group_size; $i ++) {
    my $pid = fork();#fork a new process
    $datestring = strftime "%Y_%m_%d_%H_%M", localtime;
    if (!defined($pid)) {
        print "\n- - - - - - - [*E*R*R*O*R*] - - - - - - -\nError in fork: $!\nThe time is $datestring\n- - - - - - - [*E*R*R*O*R*] - - - - - - -\n";
        exit 1;
    }
    if ($pid == 0) {
        ## == child proc ==
        $test_group = $test_groups[$i];
        $module = $module_test_group{$test_group};
        push(@exist_proids, $$);
        $child_pid{$$} = $module;
        $start_time{$$} = $datestring;
        check_processing("check", $$);
        print "\n- - - - - - - [*I*N*F*O*] - - - - - - -\n\$child_pid{$$}  $child_pid{$$}\nchild $i : pid = $$\n$module start\nThe time is $datestring\n- - - - - - - [*I*N*F*O*] - - - - - - -\n";
        if ($module eq 'usc' or $module eq 'USC') {
            my $run_regression = system("");
        } else {
            my $regression_dir;
            if ($module eq  ) {
                $regression_dir = "";
            } else {
                $regression_dir = "";
            }
            $run_case_number = $run_case_number_default;
            my $regression_module_log_dir_file = $regression_log_dir.$module."_log";
            my ($list_name, $getlist);
            if (-e "") { #if sim exists, then this module has run before
                $datestring = strftime "%Y_%m_%d_%H_%M", localtime;
                $list_name = $datestring."_list";
                $getlist = "";
            } else {
                $list_name = "list";
                $getlist = "";
            }
            
            my $run_regression = system("");
            $datestring = strftime "%Y_%m_%d_%H_%M", localtime;
            if ($run_regression == 0 && -e "") {
                print "\n- - - - - - - [*I*N*F*O*] - - - - - - -\n$module regression successful\nThe time is $datestring\n- - - - - - - [*I*N*F*O*] - - - - - - -\n";
                system("");
            } else {
                print "\n- - - - - - - [*E*R*R*O*R*] - - - - - - -\n$module regression failed\nThe time is $datestring\n- - - - - - - [*E*R*R*O*R*] - - - - - - -\n";
            }
        }
        exit 0;
    }
 
    $num_proc ++;
    my $real_order = $i + "1";
    my $finish_ratio = sprintf "%.0f",$real_order/$test_group_size*100;
    ## == if need to collect zombies ==
    if (($i-$num_proc-$num_collect) > 0) {
        while (($collect = waitpid(-1, WNOHANG)) > 0) {
            $num_collect ++;
            my $ref_finished_id = check_processing("finish", "");
            my $finished_id = $$ref_finished_id;
            $datestring = strftime "%Y_%m_%d_%H_%M", localtime;
            print "\n- - - - - - - [*I*N*F*O*] - - - - - - -\n$child_pid{$finished_id} has finished\nThe time is $datestring\n- - - - - - - - - - - - - - -\n";
        }
    }
    do {
        my @print_p = split(//,"process");
        print "        process                                  \r        ";
        my $word_p;
        foreach $word_p (@print_p) {
            print "$word_p";
            sleep(2);
        }
        foreach $word_p (@print_p) {
            print "\b";
            sleep(2);
        }
        print "current $real_order     total $test_group_size    [$finish_ratio %]\r";
        sleep(10);
        #foreach my $cur_pid (@exist_proids) {
        #    print "        $cur_pid started at $start_time{$cur_pid}\r";
        #    sleep(2);
        #}
    } until ($num_proc < $max_module_size);
}
system("");
exit 0;

sub check_processing {
    my $state = $_[0];
    my $sub_check_id = $_[1];
    open (PS, 'ps |') or die "$!";
    my @processes = <PS>;
    close PS;
    my (@cur_proids, $sub_finished_id);
    foreach my $ps_line (@processes){
        unless (grep (/PID/,$ps_line)) {
            $ps_line =~ s/^\s+|\s+$//g;
            my @psinfo = split(/\s+/,$ps_line);
            print "pid $psinfo[0] $psinfo[3]\n";
            if ($state eq "check" and $psinfo[0] eq $sub_check_id ) {
                print "yes $sub_check_id is here and $psinfo[3]\n";
            } elsif ($state eq "finish" and $psinfo[3] =~ /regression\.pl/) {
                push(@cur_proids, $psinfo[0]);
            }
        }
    }
    foreach my $exist_proid (@exist_proids) {
        unless (grep { $_ eq $exist_proid } @cur_proids ) {
            $sub_finished_id = $exist_proid;
            print "\$sub_finished_id $sub_finished_id\n";
        }
    }
    @exist_proids = @cur_proids;
    return(\$sub_finished_id);
}
