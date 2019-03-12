#!/usr/bin/perl -c
# Filename: regression.pl
# Author: SingularityKChen
# Date: 2019.03.11
# Edition: V5.2
use strict; 
use Getopt::Long;
use warnings;
use POSIX ":sys_wait_h";
unshift (@INC, "");
require("chip_readinfo.pl");
#************************#
#***** NEED REPLACE *****#
#************************#
my $run_case_number = '4'; #license,default
my $max_module_size = '6';
my ($filename, $module, $test_group);

GetOptions (
            'filename|f=s'    =>\$filename,
            'run_case_number|r=s'    =>\$run_case_number,
            'max_module_size|m=s'    =>\$max_module_size,
            );

my (%tadb, %module_test_group);
my ($tadb_ref, $module_test_group_ref);
($tadb_ref, $module_test_group_ref) = chip_readinfo($filename);

%module_test_group = %$module_test_group_ref;
my @test_groups = keys %module_test_group;
my $test_group_size = @test_groups;
my $tree_attain_dir = "";
my $filefolder_name = "";
## == number of proc ==
my $num_proc = 0;
 
## == number of collected ==
my $num_collect = 0;
 
my $collect;
 
## == get the child signal ==
$SIG{CHLD} = sub { $num_proc-- };
 
for (my $i = 0; $i < $test_group_size; $i ++) {
 
    ## == fork a new process ==
    my $pid = fork();
 
    if (!defined($pid)) {
        print "Error in fork: $!";
        exit 1;
    }
 
    if ($pid == 0) {
 
        ## == child proc ==
        $test_group = $test_groups[$i];
        $module = $module_test_group{$test_group};
        print "Child $i : My pid = $$\n$test_group STARTED\n";
		my $regression_dir = "";
		my $long_code = "";
		my $regression_result = system("/bin/tcsh -c 'gnome-terminal --title=\"regression_$filename$test_group\" -x tcsh -c \"$long_code; exec tcsh\" '");
		if ($regression_result == 0) {
			print $module."regression successful".$regression_result."\n";
		} else {
			print $module."regression fault".$regression_result."\n";
		}
        exit 0;
    }
 
    $num_proc ++;
 
    ## == if need to collect zombies ==
    if (($i-$num_proc-$num_collect) > 0) {
        while (($collect = waitpid(-1, WNOHANG)) > 0) {
            $num_collect ++;
            print "$test_groups[$i] FINISHED";
        }
    }
    do {
        sleep(100);
        print "PROCESSING\nas it has focked $num_proc is equal to $max_module_size\n";
    } until ($num_proc <= $max_module_size);
}
 
exit 0;