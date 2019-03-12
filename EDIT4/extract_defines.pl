#!/usr/bin/perl -w

use Cwd;
use Getopt::Long;

my $work_path = cwd();

my @collector;
my $flag = 0;
my $f;

GetOptions(
      	# 'ipDefines|i=s' => \$ipDefines,
       'chip|c=s'=> \$chip,
);

open Fin,"<","$work_path/ipDefines.vh"  || die "Can't open $ipDefines:$!\n";
open Fout, ">","$work_path/defines.list" || die "Can't open this tile:$!";

while(<Fin>)
{
    chomp;

    if (/.*ifdef.*$chip$/)
       {
            $flag = 1;
						next;
        }
    if ($flag == 1)
       {
           if(/.*endif.*/)
              {$flag = 0;}
           else
              {
                 print Fout $_;
								 print Fout "\n";
                 if (/.*define\s(.*)/)
                   {
                       push @collector,$1;
                    }
               }
			 }			 
}

close(Fin);

foreach my $f (@collector)
{
   	open Fin1,"<","$work_path/ipDefines.vh"  || die "Can't open $ipDefines:$!\n";
		 print "$f\n";
	   while(<Fin1>) 
         {
					 chomp;

					 if (/.*ifdef $f\s*$/)
               {
                 $flag = 1;
								 #print "$flag";
								 next;
                }

            if ($flag == 1)
               {
                  if(/.*endif/)
                      {$flag = 0;}
												# print "$flag";}
                  else
                      {
                        print Fout $_;
                        print Fout "\n";
                        if (/.*define\s(.*)(\s)*$/)
                           {
                              push @collector, $1;
                            }
                       }
								}
				}
  close(Fin1);
}

#print ("@collector\n");



close(Fin1);
close(Fout);
