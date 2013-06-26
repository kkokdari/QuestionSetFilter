# question set filter
# Author : Xingyu Na
# Data   : April 2012

die "qsfilter.pl cat.lab question.hed > question.filter.hed" if ($#ARGV<1);

print STDERR "Load data from file ...\n";
$lines = <>;

@qslist = grep {/QS \"/} @lines;
@lab = grep {not /QS \"/ and /\d/} @lines; # "

keys(%class) = $#qslist;
$qsnum = $#qslist;
$used = 0;
print STDERR "start filtering ...\n";
for $qsid (0..$qsnum)
{
	$qslist[$qsid]=~/\"(.*)\"\s+\{(.*?)\}/;
	$qstext = $1;
	$qsanswers = $2;
	print STDERR "  checking($qsid|$used|$qsnum):  $qsid.$qstext\t\t";
	if($qstext=~/[\<\>]\=\d+/)
	{
		die unless $qsanswers=~/^\**(.)(\d+)(.)\**,/;
		$minnum = $2;
		die unless $qsanswers=~/^\**(.)(\d+)(.)\**$/;
		$maxnum = $2;
		$leftmark = "\\".$1;
		$rightmark = "\\".$3;
		$yes = "";
		$n = 0;
		for $labid (0..$#lab)
		{
			die unless $lab[$labid]=~/$leftmark(x|\d+)$rightmark/;
			if($1 ne 'x' and $1<=$maxnum and $1>=minnum)
			{
				$n++;
				$yes.=$labid.'n';
			}
		}
	}
	else
	{
		$qsanswers=~s/\*//g;
		@answer = split /,/, $qsanswers;
		$yes = "";
		$n = 0;
		for $labid (0..$#lab)
		{
			for (@answer)
			{
				if(index($lab[$labid],$_)>=0)
				{
					$m++;
					$yes.=$labid.'n';
					last;
				}
			}
		}
	}
	if(not exists $class{$yes})
	{
		$used++;
		$class{$yes}=$qsid;
		print STDERR "($n)use\n";
		print "$qslist[$qsid]";
	}
	else
	{
		$qslist[$class{$yes}]=~/\"(.*)\"/;
		print STDERR "($n)same as: $class{$yes}.$1\n";
	}
}
print STDERR "finish.\n";