#!/usr/bin/perl 
# Filename: tree_attain.pl
# Author: SingularityKChen
# Date: 2019.03.01
# Edition: V4.0
use strict; 
use Getopt::Long; 

my ($tag, $arch, $chip, $branch, $filename);

GetOptions (
            'tag|t=s'      => \$tag,
            'arch|a=s'     => \$arch,
            'chip|c=s'      => \$chip,
            'branch|b=s'     => \$branch,
            'filename|f=s'    =>\$filename,
            );

my $tree_attain_dir = "";
my $filefolder_name = "";
my $p4_dir = $tree_attain_dir."/$filefolder_name";

chdir($tree_attain_dir);
if (-e $filefolder_name) {
	print "$filefolder_name exists!\n";
} else {
	mkdir($filefolder_name);
}
system "/bin/tcsh -c ''";
system "/bin/tcsh -c ''";
