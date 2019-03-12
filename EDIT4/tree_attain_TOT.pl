#!/usr/bin/perl 
# Filename: tree_attain_TOT.pl
# Author: SingularityKChen
# Date: 2019.03.04
# Edition: V4.1.X
# THIS IS FOR TOT TREE WHITHOUT TAG.
use strict; 
my $filename = "";
my $arch = "";
my $chip = " ";
my $branch = "";

my $tree_attain_dir = "";
my $filefolder_name = "";
my $p4_dir = $tree_attain_dir."";

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
