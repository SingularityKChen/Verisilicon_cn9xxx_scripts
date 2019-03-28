#!/usr/bin/perl 
# Filename: runspyglass.pl
# Author: SingularityKChen
# Date: 2019.03.18
# Edition: V3.6
# Servise: ***
# FOR the *** only because of the env;
# You are supposed to correct the $cp_rtl_dir;
# postdft.pl are needed if you're going to run dft;
#************************#
#******** NEW ***********#  
#** Version: V3.6
#** Date: 2019.03.18
#* *Fix the bug that the $datestring
#   equals to the starting time;
#* *Add runlog of testgroup;
#* *Better the way to see if the results 
#   is successful rather than being closed;
#
#** Version: V3.5
#** Date: 2019.03.15
#* *Add dft to this script;
#* *Rename it as runspyglass.pl;
#* *[2] for dft;
#
#** Version: V3.0
#* *Use Fork and array to run 
#   cdc and lint parallelly,
#   [0] for cdc and [1] for lint;
#* *Use strftime to show the real time;
#* *Standardized the output of log;
#* *Get $subrtl_file from chip_readinfo();
#
#** Version: V2.1
#* *Finish the script;
#************************#
use strict; 
use Getopt::Long; 
use warnings;
use POSIX ":sys_wait_h";
use POSIX qw(strftime);
unshift (@INC, "***");
require("chip_readinfo.pl");

my ($tag, $arch, $chip, $branch, $filename, $subrtl_file, $staging_file);
# $subrtl_file: $chip in encrypt.pl, use in encrypt and cp to staging
GetOptions (
            'filename|f=s'      => \$filename,
                        );

my ($tadb_ref, $module_test_group_ref, %tadb, %module_test_group);
($tadb_ref, $module_test_group_ref) = chip_readinfo($filename);
%tadb = %$tadb_ref;
%module_test_group = %$module_test_group_ref;
my $datestring;
$tag = $tadb{'tag'};
$arch = $tadb{'arch'};
$chip = $tadb{'def_chip'};
$branch = $tadb{'branch'};
$subrtl_file = $tadb{'subrtl'};
$staging_file = $tadb{'staging'};

my $cp_rtl_dir = "***";

if (-e $cp_rtl_dir) {
	print "--------------\n[*I*N*F*O*] cp rtl dir right at $cp_rtl_dir\n--------------\n";
} else {

	$datestring = strftime "%Y_%m_%d__%H_%M", localtime;
	die "--------------\n[*E*R*R*O*R*] cp rtl dir do not exists!\nThe time is $datestring\n--------------\n";
}

my $waiver_list_dir = "***";
my $filelist_head = "***";
my $filelist_tail = "***";

my (@cp_env_dir, @run_dir, @env_prepare_code, @env_prepare_results, @source_result);
my @prc = ("cdc", "lint", "dft");

#my %child_pid;#record the pid of child process
my $num_proc = 0;#number of proc
my $num_collect = 0;#number of collected
my $collect;#signal of collect
 
$SIG{CHLD} = sub { $num_proc-- };#

for (my $i = 0; $i < 3; $i++) {
#	my $i = 2;
	my $pid = fork();#fork a new process
	if (!defined($pid)) {
		$datestring = strftime "%Y_%m_%d__%H_%M", localtime;
	    print "--------------\n[*E*R*R*O*R*] Error in fork: $!\nThe time is $datestring\n--------------\n";
	    exit 1;
	}
	if ($pid == 0) {
		print "--------------\n[*I*N*F*O*] Child $i : My pid = $$\n--------------\n";
		$cp_env_dir[$i] = "***";
		$run_dir[$i] = "***";
		chdir($run_dir[$i]);
		if (-e $run_dir[$i]) {
			print "--------------\n[*I*N*F*O*] $run_dir[$i] exists!\n--------------\n";
		} else {
			mkdir($run_dir[$i]);
		}
		if ($i == 2) {
			$env_prepare_code[2] = "***";
		} else {
			$env_prepare_code[$i] = "***";
		}
		print $env_prepare_code[$i];
		$env_prepare_results[$i] = system("/bin/tcsh -c '$env_prepare_code[$i]'");
		$datestring = strftime "%Y_%m_%d__%H_%M", localtime;
		if ($env_prepare_results[$i] == 0) {
			print "\n--------------\n[*I*N*F*O*] env_prepare_results $i successful\ntag is $tag\n--------------\n";
			chdir($run_dir[$i]);
			my @tmplist = glob "rtl/$subrtl_file/*.v";
			open(FILELIST, ">", "file_list") || die "[*E*R*R*O*R*] Can't open file_list at $run_dir[$i] $!\nThe time is $datestring\n";
			print FILELIST $filelist_head;
			foreach my $tmplist_line (@tmplist){
				print FILELIST $tmplist_line."\n";
			}
			print FILELIST $filelist_tail;
			close(FILELIST);
			my $sourcecode = "***";
			my @source_result;
			$source_result[$i] = system "/bin/tcsh -c 'gnome-terminal --title=\"$prc[$i]\" -x tcsh -c \"$sourcecode; mkdir -p successful/$prc[$i]; exec tcsh\" '";
			$datestring = strftime "%Y_%m_%d__%H_%M", localtime;
			if ($source_result[$i] == 0 && -e "successful/$prc[$i]") {
				print "\n--------------\n[*I*N*F*O*] source $prc[$i] successful\ntag is $tag\n--------------\n";
				if ($i == 2) {
					my $postdft_result = system "/bin/tcsh -c '~/bin/script/postdft.pl -r $run_dir[$i]; mkdir -p successful/postdft;exec tcsh'";
					$datestring = strftime "%Y_%m_%d__%H_%M", localtime;
					if ($postdft_result == 0 && -e "successful/postdft") {
						print "\n--------------\n[*I*N*F*O*] source $prc[$i] postdft successful\ntag is $tag\n--------------\n";
					}else {
						print "\n--------------\n[*E*R*R*O*R*] source $prc[$i] postdft failed\ntag is $tag\nThe time is $datestring\n--------------\n";
					}
				}
			} else {
				print "\n--------------\n[*E*R*R*O*R*] source $prc[$i] failed\ntag is $tag\nThe time is $datestring\n--------------\n";
			}
		} else {
			print "\n--------------\n[*E*R*R*O*R*] env_prepare_results $i failed\ntag is $tag\nThe time is $datestring\n--------------\n";
		}
		exit 0;
	}
#=pot
	$num_proc ++;
	if (($i-$num_proc-$num_collect) > 0) {
	    while (($collect = waitpid(-1, WNOHANG)) > 0) {
	        $num_collect ++;
	        $datestring = strftime "%Y_%m_%d__%H_%M", localtime;
	        print "--------------\n[*I*N*F*O*] Some one has FINISHED\nThe time is $datestring\n--------------\n";
	    }
	}
	while ($num_proc == 3) {
		sleep(10);
		print ".";
	}
	print $i;
}
#=cut
exit 0;
