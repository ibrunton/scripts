#!/usr/bin/env perl

# For easily logging yoga teaching.
# Pass the number of people in the class as the only argument.
# 2016-09-28 20:33
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;

my $weekday = (localtime(time))[6];
my @daynames = ( 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
my %classes = ( 'Mon' => '1200 teaching Yoga Fundamentals \(NN\) to 1245',
    'Tue' => '1900 teaching Yoga for Runners \(NN\) to 2000',
    'Wed' => '1900 teaching Yoga for Men \(NN\) to 2000',
    'Fri' => '1200 sub-teaching Yoga for Acadia Community \(NN\) to 1300' );

my $attendance = $ARGV[0];

my $class = $classes{$daynames[$weekday]} || die ("No class defined for today.");
my $command = "llg " . $class;
$command =~ s/NN/$attendance/;

exec ($command);