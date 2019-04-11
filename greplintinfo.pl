#!/usr/bin/perl 
# Filename: greplintinfo.pl
# Author: SingularityKChen
# Date: 2019.04.10
# Edition: V3.3
#************************#
#******** NEW ***********#
#** Version: V3.3
#** Date: 2019.04.11
#* *Use the sub function of 
#   add_waive_msg_to_array to deal with the 
#   problem that write the repeat waive into 
#   waive file;
#* *Use redo to check rather than next;
#* *Write matched list into a file;

#** Version: V3.2
#** Date: 2019.04.10
#* *Add more case in msg auto adding;
#* *Make the split condition more specific;
#* *Add more characters which need to be its transferred meaning;
#
#** Version: V3.1
#** Date: 2019.04.09
#* *Add filename to waive auto;
#* *Add section to waive auto;
#* *Use function to make the script clearer;
#
#** Version: V2.1
#** Date: 2019.04.09
#* *Better the output;
#
#** Version: V2.0
#** Date: 2019.04.08
#* *Use hash with a array value to solve the problem;
#* *Don't compare the rule name anymore as grep by it;
#
#** Version: V1.0
#** Date: 2019.04.04
#* *Try to grep information with script;
#************************#
use strict;
use warnings;
use Getopt::Long;
use Switch;
$| = 1; #print immediately
my ($filename, $waive_file);
$filename = "moresimple.rpt"; #the report file
$waive_file = "spyglass_waive.tcl"; #the tcl file
GetOptions (
            'filename|f=s'    =>\$filename,
            'waivefile|w=s'    =>\$waive_file,
            );
my (%match_waive_msgs, %match_verilog_filenames, @waive_rulenames);
open (WAIVE, "<", "$waive_file")  || die "[*E*R*R*O*R*] Can't open $waive_file\n";
my @waivelinesinfo = <WAIVE>;
close (WAIVE);
my $filefolder_name = "matched_rules";
if (-e $filefolder_name) {
	print "$filefolder_name exists!\n";
} elsif (@waivelinesinfo) {
	mkdir($filefolder_name);
}

foreach my $waivelineinfo (@waivelinesinfo){ #read every line of waive file
	if ($waivelineinfo !~ /^$/) { #if not \n
		chomp($waivelineinfo);
		my @waive_line_split = split(/\s-\w+\s|\s-\w+$/,$waivelineinfo); #delete " -rule " " -msg " " -file " " -regexp$" and divide them
		my $waive_rulename = $waive_line_split[1]; #the rule name read from waive
		my $match_verilog_filename = $waive_line_split[2]; #the file name read from waive, but include the ", which need delete
		my $match_waive_msg = $waive_line_split[3]; #the msg read from waive, but include the ", which need delete
		$match_verilog_filename =~ s/^\"|\"$//g;#delete the " at the begin and end. then get the filename
		$match_waive_msg =~ s/^\"|\"$//g;#delete the " at the begin and end. then get the regular exINSIDEssion
		push(@{$match_waive_msgs{$waive_rulename}}, $match_waive_msg);
		push(@{$match_verilog_filenames{$waive_rulename}}, $match_verilog_filename);
		if (grep {$_ eq $waive_rulename} @waive_rulenames) { #if this rule name has existed
			# body...
		} else {
			push(@waive_rulenames, $waive_rulename);
		}
	}
}
print "--------------\n[*I*N*F*O*] \@waive_rulenames are @waive_rulenames\n--------------\n";
open (LINE, "<", "$filename")  || die "[*E*R*R*O*R*] Can't open $filename\n";
my (@rulelinesinfoes, @rulelinesinfo_tmp, $verilog_filename, $waive_msg, @fileinfo);
@fileinfo = <LINE>;
close (LINE);

OUTSIDE:foreach my $rule_name (@waive_rulenames){ #read every line of the spyglass report
	@rulelinesinfoes = grep /$rule_name/, @fileinfo; #@rulelinesinfoes concludes all information of this rule
	#print "@rulelinesinfoes\n";
	if (@rulelinesinfoes) { #if @rulelinesinfoes isn't null
		print "--------------\n[*I*N*F*O*] $rule_name is processing\n--------------\n";
		open (RRULE, ">", "$filefolder_name/$rule_name")  || die "[*E*R*R*O*R*] Can't open $rule_name\n";
		print RRULE "\t\t| matching list |\n";
		print ".";
		INSIDE:foreach my $rulelineinfo (@rulelinesinfoes){ #now determine every line related to this rule in the report
			my @rule_line_split = split(/\s\s\s+/,$rulelineinfo);#at least three \s,then split it, and we can get seperated information
			my $read_rulename = $rule_line_split[1];
			if ($rule_line_split[2] eq "Error" or $rule_line_split[2] eq "Warning" or $rule_line_split[2] eq "Info") { #the location of design file name and msg are different in some rules
				$verilog_filename = $rule_line_split[3];
				$waive_msg = $rule_line_split[6];
			} else {
				$verilog_filename = $rule_line_split[4];
				$waive_msg = $rule_line_split[7];
			}
			chomp($waive_msg);
			my @waive_verilog_file_name = split(/\//,$verilog_filename); #split the read filename include dir, the last one is the real file name
			if (grep {$verilog_filename =~ /$_/g } @{$match_verilog_filenames{$read_rulename}}) { #if the design file name is matched
				#print "--------------\n[*I*N*F*O*] the \$verilog_filename $verilog_filename matched\n--------------\n";
				if (grep {$waive_msg =~ /$_/} @{$match_waive_msgs{$read_rulename}}) { #if the msg is matched
					print RRULE "     \t\t$read_rulename\t$rule_line_split[0]\n";
					print ".";
				} else {
					print "--------------\n[*E*R*R*O*R*]$rule_line_split[0] $waive_msg do not match \@\{\$match_waive_msgs\{$read_rulename\}\}\n";
					print "the \$waive_msg is \n$waive_msg\n";
					print "\nas the last \@\{\$match_waive_msgs\{$read_rulename\}\} is \n${$match_waive_msgs{$read_rulename}}[-1]\n--------------\n";
					print "Now try to add the waive_msg into the $waive_file\n";
					add_waive_msg($waive_msg, ${$match_waive_msgs{$read_rulename}}[-1], $read_rulename, $waive_verilog_file_name[-1], \@{$match_waive_msgs{$read_rulename}});
					#print "$waive_msg\n";
					#print "$rulelineinfo\n";
					#goto OUTSIDE;
				}
			} else {
				print "--------------\n[*E*R*R*O*R*]$rule_line_split[0] $verilog_filename do not match \@\{\$match_verilog_filenames\{$read_rulename\}\}\n";
				print "the \$verilog_filename is \n$verilog_filename\n";
				print "\nas the last \@\{\$match_verilog_filenames\{$read_rulename\}\} is \n@{$match_verilog_filenames{$read_rulename}}[-1]\n--------------\n";
				print "Now try to add the verilog_filename into the $waive_file\n";
				#print "@{$match_waive_msgs{$read_rulename}}\n";
				add_verilog_filename($read_rulename, $waive_verilog_file_name[-1], ${$match_waive_msgs{$read_rulename}}[-1], $waive_msg, \@{$match_waive_msgs{$read_rulename}}); 
				#goto OUTSIDE;
			}
		}
		close (RRULE);
	} else {
		print "--------------\n[*W*A*R*R*I*N*G*] $rule_name \@rulelinesinfoes is empty\n--------------\n";
	}
	print "\n--------------\n"
}
print "Successfully, you can check the matched list at $filefolder_name\n";

sub add_verilog_filename {
	my $sub_read_rulename = $_[0];
	my $sub_read_rulename_match = $_[1];
	my $sub_waive_msgs_match = $_[2];
	my $sub_waive_msg = $_[3];
	my $sub_waive_msgs_ref = $_[4];
	my @sub_waive_msgs = @$sub_waive_msgs_ref;
	my $sub_print_waive = "waive -rule $sub_read_rulename -file \".*$sub_read_rulename_match\" -msg \"$sub_waive_msgs_match\" -regexp\n";
	if ($sub_waive_msg =~ /$sub_waive_msgs_match/) { #if the msg read from the reoprt can be matched by the last msg in waive, then we can just replace the filename, otherwise we may have to change the msg
		open (WAIVE, ">>", "$waive_file")  || die "[*E*R*R*O*R*] Can't open $waive_file\n";
		print WAIVE $sub_print_waive;
		close (WAIVE);
		print "Now try to rerun it\n";
		#system("greplineinfo.pl");
		add_waive_msg_to_array($sub_print_waive);
		redo INSIDE;
	} else {
		print "Can't just add the filename\n";
		print "$_[3]\n";
		print "$sub_waive_msgs_match\n";
		add_waive_msg($sub_waive_msg, $sub_waive_msgs_match, $sub_read_rulename, $sub_read_rulename_match, \@sub_waive_msgs);
	}
}

sub add_waive_msg {
	my $sub_waive_msg = $_[0];
	my $sub_waive_msgs_match = $_[1];
	my $sub_read_rulename = $_[2];
	my $sub_read_rulename_match = $_[3];
	my $sub_waive_msgs_ref = $_[4];
	my @sub_waive_msgs = @$sub_waive_msgs_ref;
	my (@msg_print_waive,$msg_print_final, @msg_print_read, $sub_print_waive);
		#transferred meaning#
	$sub_waive_msg =~ s/(\()/\\\(/g;
	$sub_waive_msg =~ s/(\))/\\\)/g;
	$sub_waive_msg =~ s/(\{)/\\\{/g;
	$sub_waive_msg =~ s/(\})/\\\}/g;
	$sub_waive_msg =~ s/(\+)/\\\+/g;
	$sub_waive_msg =~ s/(\[)/\\\[/g;
	$sub_waive_msg =~ s/(\])/\\\]/g;
	$sub_waive_msg =~ s/(\^)/\\\^/g;
	$sub_waive_msg =~ s/(\*)/\\\*/g;
	$sub_waive_msg =~ s/(\?)/\\\?/g;
	$sub_waive_msg =~ s/(\1)/\\\1/g;
	$sub_waive_msg =~ s/(\,)/\\\,/g;
	$sub_waive_msg =~ s/(\$)/\\\$/g;
	if (grep /expression: /, $sub_waive_msg) { #for W116, W362
		@msg_print_waive = split(/\\\"/,$sub_waive_msgs_match);
		@msg_print_read = split(/\"/,$sub_waive_msg);
		if (grep /For operator/, $sub_waive_msg) { #if exist operator, then read it and correct and write it into waive.
			my @msg_print_waive_operator = split(/\(|\)/,$msg_print_waive[0]);
			my @msg_print_read_operator = split(/\(|\)/,$msg_print_read[0]);
			$msg_print_waive[0] = "$msg_print_waive_operator[0]\($msg_print_read_operator[1]\)$msg_print_waive_operator[2]";
			print "\$msg_print_waive[0] $msg_print_waive[0]\n";
		}
		$msg_print_final = "$msg_print_waive[0]\\\"$msg_print_read[1]\\\"$msg_print_waive[2]\\\"$msg_print_read[3]\\\"$msg_print_waive[4]";
	}
	if (grep /LHS: '.+'/, $sub_waive_msg) { #W164a, W164b
		@msg_print_waive = split(/\' width|HS: \'/,$sub_waive_msgs_match);
		@msg_print_read = split(/\' width|HS: \'/,$sub_waive_msg);
		print "0000$msg_print_read[1]\n";
		print "$msg_print_read[3]\n";
		print "$msg_print_waive[2]\n";
		print "!!!$sub_waive_msgs_match\n";
		print "$msg_print_waive[0]\n";
		$msg_print_final = "$msg_print_waive[0]HS: \'$msg_print_read[1]\' width$msg_print_waive[2]HS: \'$msg_print_read[3]\' width$msg_print_waive[4]";
		print "final is $msg_print_final\n";
	}
	if (grep /Expr: '.+'/, $sub_waive_msg) { #W486, W484
		@msg_print_waive = split(/\\\(Expr: \'|\'\\\)/,$sub_waive_msgs_match);
		@msg_print_read = split(/\\\(Expr: \'|\'\\\)/,$sub_waive_msg);
		print "$msg_print_read[1]\n";
		print "$msg_print_read[3]\n";
		print "$msg_print_waive[2]\n";
		print "$msg_print_waive[-1]\n";
		print "$msg_print_waive[0]\n";
		$msg_print_final = "$msg_print_waive[0]\\\(Expr: '$msg_print_read[1]'\\\)$msg_print_waive[2]\\\(Expr: '$msg_print_read[3]'\\\)$msg_print_waive[4]";
		print "final is $msg_print_final\n";
	}
	if ($_[0] =~ /$msg_print_final/ && $msg_print_final !~ /^$/) { #if the msg read from the reoprt can be matched by new waive msg
		open (WAIVE, ">>", "$waive_file")  || die "--------------\n[*E*R*R*O*R*] Can't open $waive_file\n";
		$sub_print_waive = "waive -rule $sub_read_rulename -file \".*$sub_read_rulename_match\" -msg \"$msg_print_final\" -regexp\n";
		print WAIVE $sub_print_waive;
		close (WAIVE);
		print "Now try to rerun it\n";
		add_waive_msg_to_array($sub_print_waive);
		redo INSIDE;
		#system("greplineinfo.pl");
	} else {
		print "\n--------------\n[*E*R*R*O*R*] try adjust auto failed!!!!!!!!!!\n--------------\n";
		print "\$msg_print_final is $msg_print_final;\n";
		print "\$_[0] is $_[0];\n";
		print "\$sub_waive_msg is $sub_waive_msg;\n";
		exit 0;
	}
}

sub add_waive_msg_to_array { #upload the new waive into the array
	my $sub_add_waive_lineinfo = $_[0];
	chomp($sub_add_waive_lineinfo);
	my @sub_add_waive_line_split = split(/\s-\w+\s|\s-\w+$/,$sub_add_waive_lineinfo); #delete " -rule " " -msg " " -file " " -regexp$" and divide them
	my $sub_add_waive_rulename = $sub_add_waive_line_split[1]; #the rule name read from waive
	my $sub_add_match_verilog_filename = $sub_add_waive_line_split[2]; #the file name read from waive, but include the ", which need delete
	my $sub_add_match_waive_msg = $sub_add_waive_line_split[3]; #the msg read from waive, but include the ", which need delete
	$sub_add_match_verilog_filename =~ s/^\"|\"$//g;#delete the " at the begin and end. then get the filename
	$sub_add_match_waive_msg =~ s/^\"|\"$//g;#delete the " at the begin and end. then get the regular exINSIDEssion
	push(@{$match_waive_msgs{$sub_add_waive_rulename}}, $sub_add_match_waive_msg);
	push(@{$match_verilog_filenames{$sub_add_waive_rulename}}, $sub_add_match_verilog_filename);
	if (grep {$_ eq $sub_add_waive_rulename} @waive_rulenames) { #if this rule name has existed
		# body...
	} else {
		push(@waive_rulenames, $sub_add_waive_rulename);
	}
}
