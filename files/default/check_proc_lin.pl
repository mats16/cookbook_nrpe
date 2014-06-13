#!/usr/bin/perl

#------------------------------- check_proc_lin.pl
#use strict;
use Getopt::Std;

# Predefined exit codes for Nagios
%exit_codes   = ('UNKNOWN' ,-1,
                 'OK'      , 0,
                 'WARNING' , 1,
                 'CRITICAL', 2,);

# Turn this to 1 to see reason for parameter errors (if any)
$verb_err     = 1;

# Get the options
if($#ARGV le 0){ &usage; }else{ getopts('p:'); }

if (!$opt_p){
        print "*** You must select to process name!" if ($verb_err);
        &usage;
}

@proc_list = split(/,/, $opt_p);
foreach $proc (@proc_list){
	@res = `ps -ef | grep -i $proc | egrep -v 'grep|check_proc_lin.pl'`;
        if ($#res >= 0){
                push(@alive, $proc);
        }else{
                push(@dead, $proc);
        }
}
if($#dead >= 0){
        print "Process - Dead:[@dead], alive:[@alive]\n";
        exit $exit_codes{'CRITICAL'};
}else{
        print "Process - alive:[@alive]\n";
        exit $exit_codes{'OK'};
}


# Show usage
sub usage()
{
  print "\ncheck_proc_lin.pll v1.0 - Nagios Plugin\n\n";
  print "usage:\n";
  print " check_proc_lin.pl -p proc1,proc2,...\n\n";
  exit $exit_codes{'UNKNOWN'};
}
