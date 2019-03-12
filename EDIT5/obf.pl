#!/usr/bin/perl 
# Filename: obf.pl
# Author: SingularityKChen
# Date: 2019.03.08
# Edition: V5.4
#************************#
#*******IMPORTANT!*******#
# NEED TO MOVE 
# ```GetOptions``` 
# in  
# from after `my $rams`
# to before `my $cmd` 
#to get right $in and $out
#************************#
#************************#
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

my $obf_dir = ""; # or use cdobf
my $create_dir_1 = $obf_dir.$tag."";
my $create_dir_2 = $obf_dir.$tag."";
print $create_dir_1;
my $create_dir = "";
my $orgrtl_dir = "";
my $obfrtl_dir = "";
my $run_dir = "";
my $obfpl = "";
my $obfname = "";
my $filelist = "";
#************************#
#********* OVER *********#
#************************#
#************************#
#********** RUN *********#
#************************#
my $obf_result = system("/bin/tcsh -c ''");

if ( $obf_result == 0 ) {
	print "obf $filename successful".$obf_result."\n";

} else {
	print "obf $filename fault ".$obf_result."\n";
}
