#!/usr/bin/perl
# $Id: check_vmstat.pl,v 1.1.1.1 2006/12/27 06:42:54 egalstad Exp $

# check_vmstat.pl Copyright (C) 2011 Masato YANO
#


# Tell Perl what we need to use
#use strict;
use Getopt::Std;

use vars qw($opt_C $opt_W
            $free_memory $used_memory $total_memory
            $crit_level $warn_level
            %exit_codes @monitorlist
            $percent $fmt_pct 
            $verb_err $command_line);

# Predefined exit codes for Nagios
%exit_codes   = ('UNKNOWN' ,-1,
                 'OK'      , 0,
                 'WARNING' , 1,
                 'CRITICAL', 2,);

# Turn this to 1 to see reason for parameter errors (if any)
$verb_err     = 0;

# Constant
$cpu_pos      = 15;
$freemem_str1 = "MemFree:";
$freemem_str2 = "Inactive:";

# Get the options
if ($#ARGV le 0)
{
  &usage;
}
else
{
  getopts('W:C:');
}



if (!$opt_W || !$opt_C)
{
  &usage;
}

($cpu_w, $mem_w) = split(/,/, $opt_W);
($cpu_c, $mem_c) = split(/,/, $opt_C);

open(COMMAND, 'vmstat 1 5|') or die;
$r=0; $c=0; $cpu=0; $freemem=0;
while (<COMMAND>){
	if( $r < 3){
		$r++;
		next;
	}
	chomp;
	@data = split(/\s+/, $_);
	$cpu += $data[$cpu_pos];
	$c++;
}
$cpu = $cpu / $c;
#Making a return string for CPU Idle
$cpu_str = "CPU Idle(".$cpu."%)";


open(COMMAND, 'cat /proc/meminfo|') or die;
$freemem=0;
while (<COMMAND>){
	chomp;
	@data = split(/\s+/, $_);
	if ( $data[0] eq $freemem_str1 || $data[0] eq $freemem_str2 ){
		$freemem += $data[1];
	}
}
$mem = $freemem;


#Making a return string for Free Memory
if($freemem > 1024*1024){
	$freemem_str = int(($freemem*10)/(1024*1024))/10 ."GB";
}elsif($freemem > 1024){
	$freemem_str = int(($freemem*10)/1024)/10 ."MB"; 
}else{
	$freemem_str = $freemem ."kB";
}
$freemem_str = "Free memory(".$freemem_str.")";


#Judgment of CPU Idle
if($cpu <= $cpu_c){
	push(@crit, $cpu_str); $flg_crit = 1;
}elsif($cpu > $cpu_c && $cpu <= $cpu_w){
	push(@warn, $cpu_str); $flg_warn = 1;
}else{
	push(@good, $cpu_str);
}

#Judgment of Free Memory
if($mem <= $mem_c){
	push(@crit, $freemem_str); $flg_crit = 1;
}elsif($mem > $mem_c && $mem <= $mem_w){
	push(@warn, $freemem_str); $flg_warn = 1;
}else{
	push(@good, $freemem_str);
}

open(COMMAND, 'ps auxww -L | grep -v PID | sort -r -k 4 | head -5 | ') or die;
while($top=<COMMAND>)
{
        $top =~ s/^ +//;
        chomp;
        ($USER,$PID,$LWP,$CPU,$NLWP,$MEM,$VSZ,$RSS,$TTY,$STAT,$START,$TIME,@COMMAND)=split(/\s+/,$top);

        $comm=join(" ",@COMMAND);
        $_top .= "[$USER:$PID:$CPU\%:$VSZ:$comm] ";
}
close(COMMAND);



#$tailer = "CPU USAGE TOP5>>[USER:PID:CPU(%):VSZ(KB):CMD]$_top\n";
$tailer = "CPU USAGE:$_top\n";


if ( $flg_crit == 0 && $flg_warn == 0 ){
        print "Resource - Good:[@good]   ".$tailer;
        exit $exit_codes{'OK'};
}elsif ( $flg_crit == 1 ){
        print "Resource - Critical:[@crit], Warning:[@warn], Good:[@good]   ".$tailer;
        exit $exit_codes{'CRITICAL'};
}elsif ( $flg_warn == 1 ){
        print "Resource - Warning:[@warn], Good:[@good]   ".$tailer;
        exit $exit_codes{'WARNING'};
}else{
        print "Resource - Critical:[@crit], Warning:[@warn], Good:[@good]   ".$tailer;
        exit $exit_codes{'UNKNOWN'};
}



# Show usage
sub usage()
{
  print "\ncheck_vmstat.pl v1.0 - Nagios Plugin\n\n";
  print "usage:\n";
  print " check_vmstat.pl -Ccpu_idle[%],mem_free[KB] -Wcpu_idle[%],mem_free[KB]\n\n";
  exit $exit_codes{'UNKNOWN'}; 
}

