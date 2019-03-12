#!/usr/bin/perl 
# Filename: cdc_lint.pl
# Author: SingularityKChen
# Date: 2019.03.05
# Edition: V1.0
# FOR the VIP chip only because of the env
use strict; 
my $filename = "";
my $arch = "";
my $chip = "";
my $tag = "";
my $branch = "";
my $subrtl_file = ""; #the name of subfilefolder in rtl
my $cp_rtl_dir = "";


my $cp_cdc_env_dir = "";
my $cp_lint_env_dir = "";

my $cdc_dir = "";
my $lint_dir = "";

my $waiver_list_dir = "";

chdir($cdc_dir);
if (-e $cdc_dir) {
	print "$cdc_dir exists!\n";
} else {
	mkdir($cdc_dir);
}
chdir($lint_dir);
if (-e $lint_dir) {
	print "$lint_dir exists!\n";
} else {
	mkdir($lint_dir);
}

#my =~ /+incdir+./rtl/inc/;
my $env_prepare_cdc_rtl = system "/bin/tcsh -c ''";
my $env_prepare_lint_rtl = system "/bin/tcsh -c ''";
