#!/usr/bin/perl
# Filename: subregression.pl
# Author: SingularityKChen
# Date: 2019.04.30
# Version: V1.0
#************************#
#******** NEW ***********#
#** Version: V1.0
#** Date: 2019.04.30
#* *Rewrite the multirun script and add a funtion check_processing to print condition dynamicly;
#************************#
use strict; 
use Getopt::Long;
use warnings;
use POSIX ":sys_wait_h";
use POSIX qw(strftime);
use Switch;
my ($datestring, $list_name, $run_case_number, $regression_dir);
GetOptions (
            'listname|l=s'    =>\$list_name,
            'number|n=s'    =>\$run_case_number,
            'redir|d=s'    =>\$regression_dir,
            );
$| = 1;
chdir("$regression_dir");
open (LIST, "<", "$list_name")  || die "[*E*R*R*O*R*]\nCan't open $list_name $!\n";
my @list = <LIST>;
close(LIST);
my $father_pid = $$;
my $list_size = @list;
my @copy_list = @list;
my (@exist_proids, $casename, %start_time, $finish_ratio);
#my %child_pid;#record the pid of child process
my $num_proc = 0;#number of proc
my $num_collect = 0;#number of collected
my $collect;#signal of collect
for (my $cur_list = 0; $cur_list < $list_size; $cur_list++) {
	$casename = $copy_list[$cur_list];
	my $pid = fork();#fork a new process
	$datestring = strftime "%Y_%m_%d_%H_%M", localtime;
	if (!defined($pid)) {
	    print "\n- - - - - - - [*E*R*R*O*R*] - - - - - - -\nError in fork: $!\nThe time is $datestring\n- - - - - - - [*E*R*R*O*R*] - - - - - - -\n";
	    exit 1;
	}
	if ($pid == 0) {
		#print "\n[*I*N*F*O*] Child $cur_list : My pid = $$\n";
		push(@exist_proids, $$);
	    $start_time{$$} = $datestring;
	    print "\$start_time{$$} $start_time{$$}\n";
	    my $command = "runsim -q --rerun-fails $casename";
		system($command);
		exit 0;
	}
	my $real_order = $cur_list + "1";
	$finish_ratio = sprintf "%.0f",$real_order/$list_size*100;
	## == if need to collect zombies ==
	if (($cur_list-$num_proc-$num_collect) > 0) {
	    while (($collect = waitpid(-1, WNOHANG)) > 0) {
	        $num_collect ++;
	        check_processing(); #update the newest processing id;
	    }
	}
	check_processing();
	while ($num_proc eq $run_case_number) {
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
	 	print "current $real_order     total $list_size    [$finish_ratio %]\r";
	 	sleep(10);
	 	#foreach my $cur_pid (@exist_proids) {
	 	    #print "        $cur_pid started at $start_time{$cur_pid}\r";
	 	    #sleep(2);
	 	#}
	 }
}


sub check_processing {
	open (PS, 'ps |') or die "$!";
	my @processes = <PS>;
	close PS;
	my @cur_proids;
	foreach my $ps_line (@processes){
		unless (grep (/PID/,$ps_line)) {
			$ps_line =~ s/^\s+|\s+$//g;
			my @psinfo = split(/\s+/,$ps_line);
			if ($psinfo[3] =~ /^subregression/ and $psinfo[0] ne $father_pid) {
				push(@cur_proids, $psinfo[0]);
			}
		}
	}
	@exist_proids = @cur_proids;
	$num_proc = @exist_proids;
}
