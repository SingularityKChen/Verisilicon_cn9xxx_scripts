#!/usr/bin/perl 
# Filename: tree_attain.pl
# Author: SingularityKChen
# Date: 2019.03.08
# Edition: V5.0
use strict; 
use Getopt::Long; 
unshift (@INC, "");
require("chip_readinfo.pl");

my ($tag, $arch, $chip, $branch, $filename);
GetOptions (
            'filename|f=s'    =>\$filename,
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

my $tree_attain_dir = "";
my $filefolder_name = "";
my $p4_dir = "";

chdir($tree_attain_dir);
if (-e $filefolder_name) {
	print "$filefolder_name exists!\n";
} else {
	mkdir($filefolder_name);
}
system "/bin/tcsh -c ''";
system "/bin/tcsh -c ''";
