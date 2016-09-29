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
    'Wed' => '1900 teaching Yoga for Men \(NN\) to 2000' );

my $attendance = $ARGV[0];

my $command = "llg " . $classes{$daynames[$weekday]};
$command =~ s/NN/$attendance/;

exec ($command);
