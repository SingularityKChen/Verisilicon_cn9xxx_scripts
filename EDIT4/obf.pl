#!/usr/bin/perl 
# Filename: obf.pl
# Author: SingularityKChen
# Date: 2019.03.07
# Edition: V5.3
#************************#
#*******IMPORTANT!*******#
# NEED TO MOVE 
# ```GetOptions``` 
# in encrypt.pl 
# from after `my $rams`
# to before `my $cmd` 
#to get right $in and $out
#************************#
#************************#
use strict; 
use Getopt::Long; 
my $filename = "";
my $subrtl_file =""; # $chip in encrypt.pl, use in encrypt and cp to staging
my $arch = "";
my $tag = "";
my $branch = "";
#my $cp_orgrtl_dir = "/data/share/QA/release_kit/HW/".uc($subrtl_file)."/".$tag."/rtl";
#my $cp_obfrtl_dir = "/data/share/QA/release_kit/HW/".uc($subrtl_file)."/".$tag."_obf/rtl";
=pot
my ($tag, $filename, $arch);

GetOptions (
            'tag|t=s'      => \$tag,
            'arch|a=s'      => \$arch,
            'filename|f=s'      => \$filename,
                        );
=cut
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