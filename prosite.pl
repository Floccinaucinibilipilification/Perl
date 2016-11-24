#!/usr/bin/perl -w
use strict;
my $usage = "This script is to search a protein sequence database with a PROSITE pattern.
usage: ./prosite.pl \"PROSITE_pattern\" databse_filename
";
die $usage if @ARGV != 2;
# convert the PROSITE pattern to a Perl regular expression
my $regular_expression = "";
$ARGV[0] =~ s/\.//;
my @pattern = split(/-/,$ARGV[0]);  # 以'-'为分隔符分开各项
my $length = @pattern;
my $head = 0;
my $tail = 0;
for (my $i=0;$i<$length;$i++){
    if ($pattern[$i] ne "<" && $pattern[$i] ne ">"){
	$pattern[$i] =~ s/{/[^/;
	$pattern[$i] =~ s/}/]/;
	$pattern[$i] =~ s/\(/{/;
	$pattern[$i] =~ s/\)/}/;
	$pattern[$i] =~ s/\>/\$/;   # 替换[]中的'>'为'$',如以下这种情况:[MF]-x-[K>].
	$pattern[$i] =~ s/x/./;
    }
    elsif ($pattern[$i] eq "<"){
        $pattern[$i] =~ s/\<//;
	$head = 1;
    }
    else {
        $pattern[$i] =~ s/\>//;
        $tail = 1;
    }
    $regular_expression = $regular_expression.$pattern[$i];
}
if ($head == 1){
    $regular_expression = "\^".$regular_expression;
}
elsif ($tail == 1){
    $regular_expression = $regular_expression."\$";
}
print "The corresponding regular expression: ", $regular_expression;
# extract information
my $database_filename = $ARGV[1];
open(DATABASE,$database_filename)||die("open $database_filename error!\n");
print "\nStart\tEnd\tName\t\tDescription\n"; #Title
my $sequence = "";
my @id;
my @description;
my $start = 0;
my $end = 0;
my $flag = 0;
my $count;
my $find = 0;
while(my $line = <DATABASE>){
    chomp($line);
    if($line =~ m/^>([\w\t\-_\,\s.:\\\/\(\)]+)(protein_id:([\w.]+))/){
	$flag = $flag+1;
        $id[$flag] = $3;
        $description[$flag] = $1;
        if ($flag > 1){
            $count = 0;
            while ($sequence =~ m/($regular_expression)/g){
                $find = 1;
                my $len = length($1);
                $end = pos($sequence)-1 + $count;
                $start = $end-$len+1;
                print "$start\t$end\t$id[$flag-1]\t$description[$flag-1]\n";
                if (length($sequence) > $start+1-$count){
                    $sequence = substr($sequence,$start+1-$count);
                }
                else{
                    last;
                }
                $count = $start+1;
            }
        }
        $sequence = "";
    }
    else{
        $sequence = $sequence.$line;
    }
}
# process the last sequence
$count = 0;
while ($sequence =~ m/($regular_expression)/g){
    $find = 1;
    my $len = length($1);
    $end = pos($sequence)-1 + $count;
    $start = $end-$len+1;
    print "$start\t$end\t$id[$flag]\t$description[$flag]\n";
    if (length($sequence) > $start+1-$count){
        $sequence = substr($sequence,$start+1-$count);
    }
    else{
        last;
    }
    $count = $start+1;
}
# if not found
if ($find == 0){
    print "\nNOT FOUND!\n\n"
}
close DATABASE;
exit;
