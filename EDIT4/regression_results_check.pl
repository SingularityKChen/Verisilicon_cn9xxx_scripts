#!/usr/bin/perl 
# Filename: regression_results_check.pl
# Author: SingularityKChen
# Date: 2019.03.01
# Edition: V1.2
use strict; 
use POSIX qw(strftime);

my $datestring = strftime "%Y_%m_%d__%H_%M", localtime;

my $list_name = $datestring."_dir_list";

my $regression_results_check = system("/bin/tcsh -c ''");

if ($regression_results_check == 0) {
	print "Regression results are here".$regression_results_check."\n";
} else {
	print "Something wrong".$regression_results_check."\n";
}