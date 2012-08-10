#!/usr/bin/env perl

# perl
# 2012-07-11 16:05
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;
use XML::Simple;

my $home = $ENV{'HOME'};
#my $url = "http://www.chabad.org/tools/rss/zmanim.xml?c=206";
my $docurl = "http://www.chabad.org/library/article_cdo/aid/134527/jewish/About-Zmanim.htm";
my $file = "$home/.local/share/halakhic_times";

my $xml = new XML::Simple;
my $times = $xml->XMLin ($file);

my $hebdate = $times->{channel}->{hebrew_date} || die ("oopsie");
$hebdate    =~ s/(.+) (.+), (.+)/$2 $1, $3/;
my $endate  = $times->{channel}->{english_date};
$endate     =~ s/(.+), (.+) (.+), (.+)/$1, $3 $2, $4/;
my ($name, $time_hour, $time_min, $apm, $time);

format STDOUT_TOP =
 @|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
"Halakhic Times"
 @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$hebdate                               ,$endate
 ------------------------------------------------------------------------------
.

format STDOUT =
 @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @>>>>>
 $name,                                         $time
.

foreach my $t (@{$times->{channel}->{item}}) {
    if ($t->{title} =~ /^(.+?) - (\d{1,2}):(\d{2}) ([AP]M)/) {
	$name = $1;
	$time_hour = $2;
	$time_min = $3;
	$apm = $4;

	if ($apm eq 'PM') { $time_hour += 12; }
	$time = "$time_hour:$time_min";

	write;
    }
}

#print '-' x 79, "\n";
print "\n $docurl\n\n";

exit (0);
