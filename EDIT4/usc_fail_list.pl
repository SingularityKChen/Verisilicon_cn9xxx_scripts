#! /usr/bin/perl 
# Filename: usc_fail_list.pl
# Author: SingularityKChen
# Date: 2019.03.01
# Edition: V2.1
use strict; 
#use POSIX qw(strftime);

my $usc_test_group = '';

my @exist_case;
my @total_case;
my @fail_case;
my @files = glob "sim/*/simulation.log";
my @temp_exist_case;
foreach my $my_log (@files){
    open (LOG, "< $my_log");
    my $if_exist = grep /PASS/, <LOG>;
    if ($if_exist) {
        push (@temp_exist_case, $my_log);
        print $my_log."\n";
    }
    close (LOG);
}

if(!open TOTAL, "< $usc_test_group")  
{ 
    die "Open file failed: $!"; 
} 
  
my @temp_total_case = <TOTAL>; 
close TOTAL; 

chomp(@temp_exist_case); #delete /n
chomp(@temp_total_case);

foreach my $einput (@temp_exist_case) { 
    my @eline=split("\/",$einput); 
    my $ecase_value = $eline[1];
    print $ecase_value."\n";
    push(@exist_case, $ecase_value);
}# get the passed case names

foreach my $tinput (@temp_total_case){
    my @tline=split("    ",$tinput); # $tline[4] is the right total case.
    print $tline[3];
    if ( grep { $_ eq $tline[3] } @exist_case ){
        print $tline[4]." was passed\n";# if it can find $tline[4] from exist_case
    }else{
        push(@fail_case, $tline[3]);
        print $tline[4]." was failed\n";
    }
}

open(FAIL, "> fail.list");
print FAIL @fail_case;
close(FAIL);

print "finished\n"