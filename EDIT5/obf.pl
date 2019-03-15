#!/usr/bin/perl 
# Filename: obf.pl
# Author: SingularityKChen
# Date: 2019.03.13
# Edition: V5.5
#************************#
#******** NEW ***********# 
#** Version: V5.5.2
#* *Replace $tag with $filename in some dir
#
#** Version: V5.5
#* *Replace the dir with $user and $runsrv
#************************#
#*******IMPORTANT!*******#
# NEED TO MOVE //////////
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
#my $staging_cp_dir = "";
#my $cp_orgrtl_dir = $staging_cp_dir.$filename."/rtl";
#my $cp_obfrtl_dir = $staging_cp_dir.$filename."";
my $obf_dir = "/local/scratch/$user/qual/obf/"; # or use cdobf
my $obf_file_dir = $obf_dir.$filename;
my $create_dir_1 = $obf_file_dir."";
my $create_dir_2 = $obf_file_dir."";
my $orgrtl_dir = $obf_file_dir."";
my $obfrtl_dir = $obf_file_dir."";
my $run_dir = "";
my $obfpl = "~/bin/encrypt.pl";
my $obfname = "encrypt.pl";
my $filelist = $subrtl_file."_filelist.txt";
#************************#
#********* OVER *********#
#************************#
#************************#
#********** RUN *********#
#************************#
my $obf_result = system("/bin/tcsh -c ''");

} else {
	print "**************\nobf $filename fault\n**************\n";
}
