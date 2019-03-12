#!/usr/bin/perl 
# Filename: chip_readinfo.pl
# Author: SingularityKChen
# Date: 2019.03.08
# Edition: V1.1
use strict; 
use Getopt::Long; 
my $filename = "";
GetOptions (
            'filename|f=s'    =>\$filename,
            );
my $list_dir = "";
my (@lines, %tadb, %module_test_group);


open Fin,"<","$list_dir/$filename"  || die "Can't open $filename:$!\n";
@lines = <Fin>;
print @lines;
close (Fin);

foreach my $readinfo (@lines){
	chomp($readinfo);
	my $tadb_exist = grep /:/, $readinfo;
	my $module_test_group_exist = grep /\t/, $readinfo;
	if ($tadb_exist) { # if tadb_exist exist at this line
		my @tempsplit = split(":",$readinfo);
		$tempsplit[0] =~ s/(^\s+|\s+$)//g; # delete the blank space
		if ($tempsplit[0] eq "branch") {
			$tempsplit[1] =~ s/\/\/HW\///g;
		}
		$tempsplit[1] =~ s/(^\s+|\s+$)//g;
		$tadb{$tempsplit[0]} = $tempsplit[1];
		print "$tempsplit[0] = $tadb{$tempsplit[0]}\n";
	}
	if ($module_test_group_exist) {
		my @tempsplit = split("\t",$readinfo);
		$tempsplit[0] =~ s/(^\s+|\s+$)//g;
		$tempsplit[1] =~ s/(^\s+|\s+$)//g;
		if ($tempsplit[0] ne "Module") {
			$module_test_group{$tempsplit[0]} = $tempsplit[1];
		}
		print "$tempsplit[0] = $module_test_group{$tempsplit[0]}\n";
	}
}
print "read info finished\n";