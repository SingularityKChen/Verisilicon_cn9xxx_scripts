#!/usr/bin/perl 
# Filename: spyglass_waive_grep_and_write.pl
# Author: SingularityKChen
# Date: 2019.04.22
# Edition: V4.4
#************************#
#******** NEW ***********#
#** Version: V4.4
#** Date: 2019.04.22
#* *Delete W240 from the foreach loop jump list;
#* *Correct the way to splite @msg_print_waive, @msg_print_read 
#   and $msg_print_final when the rule is W240;
#* *Add sub function print_detail to print more details
#   when input option -view|v;
#
#** Version: V4.3.1
#** Date: 2019.04.19
#* *Add the -h option to print help information;
#* *Correct the location of every elements in @rule_line_split;
#
#** Version: V4.3.1
#** Date: 2019.04.19
#* *Cp the $waive_file at the beginning to $new_waive_file
#   and add waive into $new_waive_file;
#* *Add foreach loop to jump the number sign(#) and null
#   lines and rule FlopEConst|NoAssignX-ML|W240|W71;
#* *Use qw(strftime) to add comment into $new_waive_file
#   at the end of every successful run time;
#* *Change the default $waive_file;
#
#** Version: V4.2
#** Date: 2019.04.18
#* *set @match_verilog_filenames and %match_waive_msgs
#   to null at every new rule loop;
#
#** Version: V4.1
#** Date: 2019.04.18
#* *Fix the bug that msg is the same but not match
#   the parallel Verilog file name;
#* *Attach the Verilog filename and msg together
#   with $combination_verilog_msg;
#* *Delete ".*" from $match_verilog_filename;
#* *Replace the keys of %match_waive_msgs from 
#   rule names to the Verilog filenames(without ".*"), 
#   and the values are parallel msgs;
#* *Delete the subfunction &add_verilog_filename 
#   because &add_waive_msg is enough;
#* *Correct the add_waive_msg_to_array;
#* *Standardize the lables for loop;
#* *Standardize the comment of variables;
#* *Replace "verilog" to "Verilog";
#
#** Version: V4.0
#** Date: 2019.04.16
#* *Rename the file from greplintinfo.pl 
#   to spyglass_waive_grep_and_write.pl;
#* *Rewrite the structure of %match_waive_msgs,
#   %match_verilog_filenames;
#
#** Version: V3.5
#** Date: 2019.04.16
#* *Fix the bug that single quote(') is supposed not to be translated;
#
#** Version: V3.4.6
#** Date: 2019.04.15
#* *Fix the bug when the waive file is read in spyglass
#   "0-9 command no found" by replace the double quote(") with curly braces( { and } );
#* *Better the info output;
#* *Add some comment to make the script more readable;
#* *translate the expression like 16'h to 16\'h
#
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
#* *Add more characters which need to be its
#   transferred meaning;
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
#use warnings;
use Getopt::Long;
use Switch;
use POSIX qw(strftime);
$| = 1;
my ($rptfile, $waive_file, $needhelp, $view_detail);
$rptfile = "moresimple.rpt"; #the default report file
$waive_file = "waive_model.awl"; #the default awl file
GetOptions (
            'rptfile|r=s'    =>\$rptfile,
            'waivefile|w=s'    =>\$waive_file,
            'help|h'    =>\$needhelp,
            'view|v'    =>\$view_detail,
            );
die `pod2text -w 100 $0` if $needhelp; #if input the option 'h' or 'help', then print the help message
my $datestring = strftime "%Y_%m_%d_%H_%M", localtime;
my $new_waive_file = "new_".$datestring."_".$waive_file;
system("/bin/tcsh -c 'cp $waive_file $new_waive_file'"); #cp the $waive_file
my $filefolder_name = "matched_rules";
my (%match_combination_verilog_msgs, @waive_rulenames, @waivelinesinfo);
# $combination_verilog_msg: read from $new_waive_file, the combination of the Verilog file name and waive msg
# %match_combination_verilog_msgs: read from $new_waive_file, the keys are $waive_rulename, the values are every $combination_verilog_msg of this rule
# @waive_rulenames: read from $new_waive_file, the total rule waited to be waived
# @waivelinesinfo: read from $new_waive_file, concludes all the effective-rows
open (WAIVE, "<", "$new_waive_file")  || die "[*E*R*R*O*R*]\nCan't open $new_waive_file\n";
foreach my $temp_waive_line (<WAIVE>) {
	if ($temp_waive_line !~ /^#|^$|FlopEConst|NoAssignX-ML|W71/) { #if current line doesn't begin with number sign(#) or be a null line, then it's added into @waivelinesinfo; if current waive relates to FlopEConst|NoAssignX-ML|W71, then skip.
		push(@waivelinesinfo, $temp_waive_line);
	}
}
close (WAIVE);
if (-e $filefolder_name) {
	#print "$filefolder_name exists!\n";
} elsif (@waivelinesinfo) {
	mkdir($filefolder_name);
}
my $splitword = "splitword"; #used to combinate the Verilog file name and waive msg and translate them.
my $waivelineinfo; #one line of $new_waive_file
foreach $waivelineinfo (@waivelinesinfo){ #read every line of $new_waive_file
	if ($waivelineinfo !~ /^$/) { #if not \n
		chomp($waivelineinfo);
		my (@waive_line_split, $waive_rulename, $match_verilog_filename, $match_waive_msg);
		# @waive_line_split: the different part of one line from the waive file
		# $waive_rulename: the rule name read from waive
		# $match_verilog_filename: the file name read from waive, but include the " , which need delete
		# $match_waive_msg: the msg read from waive, but include the ", which need delete
		@waive_line_split = split(/\s-\w+\s|\s-\w+$/,$waivelineinfo); #delete " -rule " " -msg " " -file " " -regexp$" and divide them
		$waive_rulename = $waive_line_split[1]; 
		$match_verilog_filename = $waive_line_split[2]; 
		$match_waive_msg = $waive_line_split[3]; 
		$match_verilog_filename =~ s/^\"|\"$//g;#delete the " at the begin and end, then get the filename
		$match_waive_msg =~ s/^\{|\}$//g;#delete the { and } at the begin and end, then get the regular expression
		$match_verilog_filename =~ s/\.\*//g; #delete the ".*"
		my $combination_verilog_msg = $match_verilog_filename.$splitword.$match_waive_msg;
		push(@{$match_combination_verilog_msgs{$waive_rulename}}, $combination_verilog_msg);
		if (grep {$_ eq $waive_rulename} @waive_rulenames) { #if this rule name has existed
			# body...
		} else {
			push(@waive_rulenames, $waive_rulename);
		}
	}
}
print "--------------\n[*I*N*F*O*]\n\@waive_rulenames are @waive_rulenames\n--------------\n";
open (LINE, "<", "$rptfile")  || die "[*E*R*R*O*R*] Can't open $rptfile\n";
my (@rulelinesinfoes, $read_rulename, $verilog_filename, $waive_msg, @fileinfo);
# @rulelinesinfoes: read from $rptfile, concludes all the line from $rptfile which matched by $rule_name
# $read_rulename: read from $rptfile-@rulelinesinfoes, the rule name
# $verilog_filename: read from $rptfile-@rulelinesinfoes, the Verilog file name
# $waive_msg: read from $rptfile-@rulelinesinfoes, the msg
# @fileinfo: read from $rptfile, all the message of the $rptfile
@fileinfo = <LINE>;
close (LINE);
my ($temp_combination_verilog_msg, @split_combination_verilog_msg, @match_verilog_filenames, $split_verilog_filename, $split_msg, %match_waive_msgs);
# $temp_combination_verilog_msg: read from $new_waive_file, the combination of the Verilog file name and waive msg
# @split_combination_verilog_msg: read from $new_waive_file, the splited array of Verilog file name and msg
# $split_verilog_filename: read from $new_waive_file, Verilog file name which isn't conclude the ".*"
# @match_verilog_filenames: read from $new_waive_file, the array of Verilog filename
# $split_msg: read from $new_waive_file, msg
# %match_waive_msgs: read from $new_waive_file, keys are Verilog filenames, while the values are the parallel msgs
WAIVERULE: {
	foreach my $rule_name (@waive_rulenames){ #read every line of the spyglass report
		@rulelinesinfoes = grep /$rule_name/, @fileinfo;
		@match_verilog_filenames = ();
		%match_waive_msgs = ();
		VMSGVMSG: {
			foreach $temp_combination_verilog_msg (@{$match_combination_verilog_msgs{$rule_name}}){
				@split_combination_verilog_msg = split(/$splitword/,$temp_combination_verilog_msg);
				$split_verilog_filename = $split_combination_verilog_msg[0];
				$split_msg = $split_combination_verilog_msg[1];
				if (grep {$_ eq $split_verilog_filename} @match_verilog_filenames) { #if this Verilog filenames has existed
					# body...
				} else {
					push(@match_verilog_filenames, $split_verilog_filename);
				}
				push(@{$match_waive_msgs{$split_verilog_filename}}, $split_msg);
			}
		}
		if (@rulelinesinfoes) { #if @rulelinesinfoes isn't null
			print_detail( "--------------\n[*I*N*F*O*]\n$rule_name is processing\n--------------\n", "$rule_name is processing...");
			open (RRULE, ">", "$filefolder_name/$rule_name")  || die "[*E*R*R*O*R*] Can't open $rule_name\n";
			print RRULE "\t\t| matching list |\n";
			RULELINE:{
				foreach my $rulelineinfo (@rulelinesinfoes){ #now determine every line related to this rule in the report
					my @rule_line_split = split(/\s\s\s+/,$rulelineinfo);#at least three \s,then split it, and we can get seperated information
					$read_rulename = $rule_line_split[1];
					$verilog_filename = $rule_line_split[4];
					$waive_msg = $rule_line_split[7];
					chomp($waive_msg);
					my @waive_verilog_file_name = split(/\//,$verilog_filename); #split the read filename include dir, the last one is the real file name
					my $last_verilog_file_name = $waive_verilog_file_name[-1];
					JUDGEFILE:{
						if (grep {$_ eq $last_verilog_file_name} @match_verilog_filenames) { #if the design file name is matched
							if (grep {$waive_msg =~ /$_/} @{$match_waive_msgs{$last_verilog_file_name}}) { #if the msg is matched
								print RRULE "     \t\t$read_rulename\t$rule_line_split[0]\n";
								print_detail(".");
							} else {
								print_detail("x");
								#Now try to add the new waive into the $new_waive_file because of $waive_msg
								add_waive_msg($waive_msg, ${$match_waive_msgs{$last_verilog_file_name}}[-1], $read_rulename, $last_verilog_file_name);
							}
						} else {
							print_detail("x");
							#Now try to add the new waive into the $new_waive_file because of $last_verilog_file_name
							add_waive_msg($waive_msg, ${$match_waive_msgs{$match_verilog_filenames[0]}}[-1], $read_rulename, $last_verilog_file_name);
						}
					}
				}
			}
			close (RRULE);
			print_detail( "\n--------------\n[*I*N*F*O*]\n$rule_name done\n--------------\n" , "done\n");
		} else {
			print "--------------\n[*W*A*R*R*I*N*G*]\n$rule_name \@rulelinesinfoes is empty\n--------------\n";
		}
		print "\n--------------\n"
	}
}
print "--------------\n[*I*N*F*O*]\nSuccessfully, you can check the matched list at $filefolder_name\nAnd you can cp the $new_waive_file into sg_setup\n--------------\n";
open (WAIVE, ">>", "$new_waive_file")  || die "--------------\n[*E*R*R*O*R*] Can't open $new_waive_file\n";
my $waive_successful = "################## ABOVE $datestring ABOVE ##################\n"; # $datestring is the time begin to run this script
print WAIVE $waive_successful;
close (WAIVE);

sub add_waive_msg {
	my $sub_waive_msg = $_[0]; # deliveried from $waive_msg
	my $sub_waive_msgs_match = $_[1]; # deliveried from ${$match_waive_msgs{$read_rulename}}[-1]
	$sub_waive_msgs_match =~ s/^\{|\}$//g;
	my $sub_read_rulename = $_[2]; # deliveried from $read_rulename
	my $sub_read_rulename_match = $_[3]; # deliveried from $last_verilog_file_name
	my (@msg_print_waive,$msg_print_final, @msg_print_read, $sub_waive_print_waive);
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
	$sub_waive_msg =~ s/(\$)/\\\$/g;
	$sub_waive_msg =~ s/(\&)/\\\&/g;
	$sub_waive_msg =~ s/(\|)/\\\|/g;
	#$sub_waive_msg =~ s/(\<)/\\\</g;
	#$sub_waive_msg =~ s/(\>)/\\\>/g;
	#$sub_waive_msg =~ s/([0-9]+)\'([bdh])/$1\\\'$2/g; # something like 16'h to 16\'h
	switch($sub_read_rulename){ #to generate new msg
		case /W116|W362|STARC-2\.10\.3\.2c/ { #for W116, W362
			@msg_print_waive = split(/\\\"/,$sub_waive_msgs_match);
			@msg_print_read = split(/\"/,$sub_waive_msg);
			if (grep /For operator/, $sub_waive_msg) { #if exist operator, then read it and correct and write it into waive.
				my @msg_print_waive_operator = split(/\(|\)/,$msg_print_waive[0]);
				my @msg_print_read_operator = split(/\(|\)/,$msg_print_read[0]);
				$msg_print_waive[0] = "$msg_print_waive_operator[0]\($msg_print_read_operator[1]\)$msg_print_waive_operator[2]";
				print_detail("/");
			}
			$msg_print_final = "$msg_print_waive[0]\\\"$msg_print_read[1]\\\"$msg_print_waive[2]\\\"$msg_print_read[3]\\\"$msg_print_waive[4]";
		}
		case /W164[ab]|STARC-2\.10\.3\.2b/ { #W164a, W164b, STARC-2.10.3.2b
			@msg_print_waive = split(/\' width|HS: \'/,$sub_waive_msgs_match);
			@msg_print_read = split(/\' width|HS: \'/,$sub_waive_msg);
			#print "0000$msg_print_read[1]\n";
			#print "$msg_print_read[3]\n";
			#print "$msg_print_waive[2]\n";
			#print "!!!$sub_waive_msgs_match\n";
			#print "$msg_print_waive[0]\n";
			$msg_print_final = "$msg_print_waive[0]HS: \'$msg_print_read[1]\' width$msg_print_waive[2]HS: \'$msg_print_read[3]\' width$msg_print_waive[4]";
			print_detail("*");
		}
		case /W486|W484/ { #W486, W484
			@msg_print_waive = split(/\\\(Expr: \'|\'\\\)/,$sub_waive_msgs_match);
			@msg_print_read = split(/\\\(Expr: \'|\'\\\)/,$sub_waive_msg);
			#print "\$sub_waive_msg is $sub_waive_msg\n";
			#print "\@msg_print_read 1 and 3\n";
			#print "$msg_print_read[1]\n";
			#print "$msg_print_read[3]\n--------------\n";
			#print "\$sub_waive_msgs_match is $sub_waive_msgs_match\n";
			#print "\$_[1] is $_[1]\n";
			#print "\@msg_print_waive 0 2 and -1\n";
			#print "$msg_print_waive[0]\n";
			#print "$msg_print_waive[2]\n";
			#print "$msg_print_waive[-1]\n";
			$msg_print_final = "$msg_print_waive[0]\\\(Expr: \'$msg_print_read[1]\'\\\)$msg_print_waive[2]\\\(Expr: \'$msg_print_read[3]\'\\\)$msg_print_waive[4]";
			print_detail("-");
		}
		case "W240" {
			@msg_print_waive = split(/\s\'|\'\s/,$sub_waive_msgs_match);
			@msg_print_read = split(/\s\'|\'\s/,$sub_waive_msg);
			$msg_print_final = "$msg_print_waive[0] \'$msg_print_read[1]\' $msg_print_waive[-1]";
			print_detail("+");
		}
		else { } #no need
	}
	if ($_[0] =~ /$msg_print_final/ && $msg_print_final ne "\n") { #if the msg read from the reoprt can be matched by new waive msg
		open (WAIVE, ">>", "$new_waive_file")  || die "--------------\n[*E*R*R*O*R*] Can't open $new_waive_file\n";
		$sub_waive_print_waive = "waive -rule $sub_read_rulename -file \".*$sub_read_rulename_match\" -msg {$msg_print_final} -regexp\n";
		print WAIVE $sub_waive_print_waive;
		close (WAIVE);
		#Now try to rerun it
		add_waive_msg_to_array($sub_waive_print_waive);
		redo JUDGEFILE;
	} else {
		print "\n--------------\n[*E*R*R*O*R*] Try adjust auto failed!!!!!!!!!!\nBegan at $datestring\n--------------\n";
		print "\$sub_read_rulename is $sub_read_rulename;\n";
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
	$sub_add_match_waive_msg =~ s/^\{|\}$//g;#delete the " at the begin and end. then get the regular expression
	$sub_add_match_verilog_filename =~ s/\.\*//g;
	push(@{$match_waive_msgs{$sub_add_match_verilog_filename}}, $sub_add_match_waive_msg);
	if (grep {$_ eq $sub_add_match_verilog_filename} @match_verilog_filenames) { #if this Verilog filenames has existed
		# body...
	} else {
		push(@match_verilog_filenames, $sub_add_match_verilog_filename);
	}
}

sub print_detail {
	if ($view_detail) {
		print $_[0];
	} elsif ($_[1]) {
		print $_[1];
	} else {
		# else...
	}
}

=pod

=for text

=over 2

=head1 Description

spyglass_waive_grep_and_write.pl is a script to read the report produced by spyglass, and compared the generated messages with the waivefile.

If one message can not be matched by the regular expressions in the waivefile, then write the parallel waive into the end of waivefile.

If you want to see every detail while processing, you can simply -v or -view. And the infomation printed on the screen, "." means this report message can be waived by spyglass now; "x" means this report message can not be waived right now but this script will try to correct it. "/" "*" "-" or "+" mean this report message is processed by different rules.

=head1 Read In and Write Out

This script read in two files: rptfile (named $rptfile, default:moresimple.rpt) and waivefile (named $waive_file, default:waive_model.awl).

Then it write out a new waivefile (named $new_waive_file) and a direction (named $filefolder_name, default:matched_rules).

The direction concludes some files named by rule names, and those files show the labe of each message in rptfile.

=head1 Usage

for short options:

spyglass_waive_grep_and_write.pl -r <rptfile> -w <waivefile> [-v] [-h]

for long options:

spyglass_waive_grep_and_write.pl -rptfile <rptfile> -waivefile <waivefile> [-view] [-help]

=head1 Options

-rptfile|r  [str]		the default report file(default:moresimple.rpt)

-waivefile|w  [str]		the default awl file(default:waive_model.awl)

-view|v 				print more detail information while processing

-help|h 				print this help information

=head1 Example

spyglass_waive_grep_and_write.pl -r moresimple.rpt -w waive_model.awl

spyglass_waive_grep_and_write.pl -v -r violations.rpt -w waive_model.awl

spyglass_waive_grep_and_write.pl -h

=cut
