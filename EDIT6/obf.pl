#!/usr/bin/perl 
# Filename: obf.pl
# Author: SingularityKChen
# Date: 2019.03.14
# Edition: V6.0
#************************#
#******** NEW ***********# 
#** Version: V6.0
#* *Use the newest chip_readinfo.pl;
#* *Better the code of copying to `staging`;
#* *Standardized the output of log;
#
#** Version: V5.5.2
#* *Replace $tag with $filename in some dir;
#
#** Version: V5.5
#* *Replace the dir with $user and $runsrv;
#************************#
#*******IMPORTANT!*******#
# NEED TO MOVE 
# ```GetOptions``` 
# in encrypt.pl 
# from after `my $rams`
# to before `my $cmd` 
# to get right $in and $out
# IF YOU PUT THIS FILE AT BIN,
# THEN YOU NEED TO RENAME IT.
#************************#
#************************#
use strict; 
use warnings;
use Getopt::Long; 
unshift (@INC, "");
require("chip_readinfo.pl");
require("host_user.pl");

my ($tag, $arch, $chip, $branch, $filename, $subrtl_file, $staging_file);
# $subrtl_file: $chip in encrypt.pl, use in encrypt and cp to staging
GetOptions (
            'filename|f=s'      => \$filename,
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
$subrtl_file = $tadb{'subrtl'};
$staging_file = $tadb{'staging'};
my $obf_dir = ""; # or use cdobf
my $obf_file_dir = $obf_dir.$filename;
my $create_dir_1 = "";
my $create_dir_2 = "";
my $orgrtl_dir = "";
my $obfrtl_dir = "";
my $run_dir = "";
my $obfpl = "";
my $obfname = "encrypt.pl";
my $filelist = "";
#************************#
#********* OVER *********#
#************************#
#************************#
#********** RUN *********#
#************************#
my $obf_result = system("/bin/tcsh -c ''");
if ( $obf_result == 0 ) {
	print "--------------\n[*I*N*F*O*] obf $filename successful\n--------------\n";
} else {
	print "--------------\n[*E*R*R*O*R*] obf $filename fault\n--------------\n";
}