#!/usr/bin/perl 
# Filename: tree_attain_TOT.pl
# Author: SingularityKChen
# Date: 2019.03.04
# Edition: V5.1.X
# THIS IS FOR TOT TREE WHITHOUT TAG.
use strict; 
use Getopt::Long; 
unshift (@INC, "");
require("chip_readinfo.pl");
my ($arch, $chip, $branch, $filename);
GetOptions (
            'filename|f=s'    =>\$filename,
            );

my (%tadb, %module_test_group);
my ($tadb_ref, $module_test_group_ref);
($tadb_ref, $module_test_group_ref) = chip_readinfo($filename);
%tadb = %$tadb_ref;
%module_test_group = %$module_test_group_ref;

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
my $p4_result = system "/bin/tcsh -c ''";
if ( $p4_result = 0) {
	print $filename."p4 successful".$p4_result."\n";
	my $makerelease_result = system "/bin/tcsh -c ''";
	print $makerelease_result."\n";
}else{
	print $filename."p4 fault".$p4_result."\n";
	break;
}
