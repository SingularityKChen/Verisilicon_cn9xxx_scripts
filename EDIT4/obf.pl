#!/usr/bin/perl 
# Filename: obf.pl
# Author: SingularityKChen
# Date: 2019.03.07
# Edition: V5.3
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
my $filename = "";
my $subrtl_file =""; 
my $arch = "";
my $tag = "";
my $branch = "";
my $obf_dir = ""; # or use cdobf
my $create_dir_1 = "";
my $create_dir_2 = "";
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
