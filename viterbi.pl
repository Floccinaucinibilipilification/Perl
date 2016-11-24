#!/usr/bin/perl -w
use strict;
my ($example) = @ARGV;
my $usage = "This script is to find maximum likelihood state path and maximum likelihood
guess for the position which was the first flip of the biased coin for each sequence.
usage: $0 example
";
die $usage if @ARGV < 1;
my $result=$example.".result";
open(EXAMPLE, $example)||die("Cannot open $example!\n");
open(OUT,">$result")||die("Cannot write results to $result!\n");
my $e_F = 0.5;       # e:emission probability    a:state transition probability
my $e_BH = 0.8;      # F:fair    B:biased    H:head    T:tail    E:end
my $e_BT = 0.2;
my $a_F2F = 0.99;
my $a_F2B = 0.01;
my $a_B2B = 0.95;
my $a_B2E = 0.05;
my $c = 1;           # record the position corresponding to the max probability
while(my $line = <EXAMPLE>){
	chomp($line);
	my $l = length($line);
	my @group = split(//,$line);
	my @p;
	$p[1]=1/$a_F2F;  # the first coin must be the fair one
	my $max = 0;     # record the max probability
	my $i;
	my $j;
	for ($i=2;$i<=$l;$i++){
		for ($j=1;$j<$i;$j++){
			$p[$j+1] = $p[$j] * $e_F * $a_F2F;
		}
		$p[$i] = $p[$j] * $a_F2B / $a_B2B;
		for (my $k=$i;$k<=$l;$k++){
			if ($group[$k-1] eq "H"){
				$p[$i] = $p[$i] * $e_BH * $a_B2B;
			}
			else{
				$p[$i] = $p[$i] * $e_BT * $a_B2B;
			}
		}
		$p[$i] = $p[$i] * $a_B2E;
		if ($max < $p[$i]){
			$max = $p[$i];
			$c = $i;
		}
	}
	for ($i=1;$i<$c;$i++){
		print OUT "1";
	}
	for ($i=$c;$i<=$l;$i++){
		print OUT "2";
	}
	print OUT "\t".$c."\n";
}
close EXAMPLE;
close OUT;
exit;
