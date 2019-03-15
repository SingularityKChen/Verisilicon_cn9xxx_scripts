#!/usr/bin/perl 
# Filename: chip_readinfo.pl
# Author: SingularityKChen
# Date: 2019.03.12
# Edition: V2.0
# New:	Version: V2.0
#		Add warnings module
#		Fix the $list_dir
use strict;
sub chip_readinfo {
	my $filename = $_[0];
	my $list_dir = "";
	my (@lines, %tadb, %module_test_group);
	print "Reading chip information from $list_dir$filename\n";
	open(Fin,"<", $list_dir.$filename)  || die "Can't open $filename:$!\n";
	@lines = <Fin>;
	print @lines;
	close (Fin);
	print "\n\nthe chip information is as following\n********************\n";
	foreach my $readinfo (@lines){
		chomp($readinfo);
		my $tadb_exist = grep(/:/, $readinfo);
		my $module_test_group_exist = grep(/\t/, $readinfo);
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
			if ($tempsplit[0] ne "Module" && $tempsplit[0] ne "usc") {
				$module_test_group{$tempsplit[1]} = $tempsplit[0];
				print "$tempsplit[1] = $module_test_group{$tempsplit[1]}\n";
			}
		}
	}
	print "********************\nread info finished\n";
	return( \%tadb, \%module_test_group );
}
1;
