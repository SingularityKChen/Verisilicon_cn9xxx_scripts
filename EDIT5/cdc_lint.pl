#!/usr/bin/perl 
# Filename: cdc_lint.pl
# Author: SingularityKChen
# Date: 2019.03.08
# Edition: V2.0
# FOR the VIP chip only because of the env
use strict; 
use Getopt::Long; 
unshift (@INC, "");
require("chip_readinfo.pl");

my ($tag, $arch, $chip, $branch, $filename, $subrtl_file);
GetOptions (
            'filename|f=s'      => \$filename,
            'subrtl|s=s'      => \$subrtl_file,
                        );

my (%tadb, %module_test_group);
my ($tadb_ref, $module_test_group_ref);
($tadb_ref, $module_test_group_ref) = chip_readinfo($filename);
%tadb = %$tadb_ref;
%module_test_group = %$module_test_group_ref;

$tag = $tadb{'tag'};
$arch = $tadb{'arch'};
$chip = $tadb{'chip'};
$branch = $tadb{'branch'};

my $cp_rtl_dir = "";

my $cp_cdc_env_dir = "";
my $cp_lint_env_dir = "";

my $cdc_dir = "".$tag;
my $lint_dir = "".$tag;

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

my $env_prepare_cdc_rtl = system "/bin/tcsh -c ''";
my $env_prepare_lint_rtl = system "/bin/tcsh -c ''";
