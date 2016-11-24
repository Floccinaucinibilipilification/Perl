#!/usr/bin/perl -w
use strict;
my ($example) = @ARGV;
my $usage = "This script is to find out the best (most probable) five positions, 
followed by the summed posterior probability of all five, for each sequence.
usage: $0 example
";
die $usage if @ARGV < 1;
my $fb=$example.".fb";
open(EXAMPLE, $example)||die("Cannot open $example!\n");
open(OUT,">$fb")||die("Cannot write results to $fb!\n");
my $e_F = 0.5;     # e:emission probability
my $e_BH = 0.8;    # a:state transition probability
my $e_BT = 0.2;    # F:fair    B:biased
my $a_F2F = 0.99;  # H:head    T:tail    E:end
my $a_F2B = 0.01;
my $a_B2B = 0.95;
my $a_B2E = 0.05;
while(my $line = <EXAMPLE>){
	chomp($line);
	my $l = length($line);
	my @group = split(//,$line);
	my @p;     # posterior probability,but only with the molecular part
			   # because the denominator value is fixed
	$p[1] = 1/$a_F2F;
	my @array;  # record five biggest possibilities
	my @c;      # record five positions
	my $sum=0;  # summed forward probability
	my $i;
	my $j;
	for ($i=2;$i<=$l;$i++){
		for ($j=1;$j<$i;$j++){                # forward
			$p[$j+1] = $e_F * $p[$j] * $a_F2F;
		}
		if ($group[$i-1] eq "H") {
			$p[$i] = $p[$j] * $a_F2B * $e_BH; # forward probability
			$sum = $sum + $p[$i];
		}
		else{
			$p[$i] = $p[$j] * $a_F2B * $e_BT;
			$sum = $sum + $p[$i];
		}
		for (my $k=$i+1;$k<=$l;$k++){         # backward
			if ($group[$k-1] eq "H"){
				$p[$i] = $p[$i] * $e_BH * $a_B2B;
			}
			else{
				$p[$i] = $p[$i] * $e_BT * $a_B2B;
			}
		}
		$p[$i] = $p[$i] * $a_B2E;
		my $n = 0;
		while ($n<5){
			if($i <= 6){
				$array[$i-2] = $p[$i];
				$c[$i-2] = $i;
				last;
			}
			elsif ($array[$n] < $p[$i]){
				$array[$n] = $p[$i];
				$c[$n] = $i;
				last;
			}
			else{
				$n++;
			}
		}
	}
	$sum = ($array[0]+$array[1]+$array[2]+$array[3]+$array[4]) / $sum;
	print OUT $c[0]."\t".$c[1]."\t".$c[2]."\t".$c[3]."\t".$c[4]."\t";
	print OUT "summed posterior probability: ".$sum."\n";
}
close EXAMPLE;
close OUT;
exit;
