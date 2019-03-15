#!/usr/bin/perl 
# Filename: tree_attain.pl
# Author: SingularityKChen
# Date: 2019.03.12
# Edition: V5.1
# New:	Version: V5.1
#		Replace the dir with $user and $runsrv
use strict; 
use Getopt::Long; 
use warnings;
unshift (@INC, "/home/cn9259/bin/script/");
require("chip_readinfo.pl");
require("host_user.pl");

my ($tag, $arch, $chip, $branch, $filename);
GetOptions (
            'filename|f=s'    =>\$filename,
            );

my ($tadb_ref, $module_test_group_ref, %tadb, %module_test_group);
($tadb_ref, $module_test_group_ref) = chip_readinfo($filename);
%tadb = %$tadb_ref;
%module_test_group = %$module_test_group_ref;

my ($user_ref, $runsrv_ref, $user, $runsrv);
($user_ref, $runsrv_ref) = host_user();
$user = $$user_ref;
$runsrv = $$runsrv_ref;

$tag = $tadb{'tag'};
$arch = $tadb{'arch'};
$chip = $tadb{'def_chip'};
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
my $get_tree_result = system "/bin/tcsh -c ''";
if ($get_tree_result == 0) {
	print "**************\n $filefolder_name get_tree_result successful\n**************\n";
	my $makerelease_result = system "/bin/tcsh -c ''";
	if ($makerelease_result == 0) {
		print "**************\n $filefolder_name makerelease successful\n**************\n";
	} else {
		print "**************\n $filefolder_name makerelease fault\n**************\n";
	}
} else {
	print "**************\n $filefolder_name get_tree_result fault\n**************\n";
}
