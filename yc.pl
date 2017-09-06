#!/usr/bin/env perl

# For easily logging yoga teaching.
# Pass the number of people in the class as the only argument.
# 2016-09-28 20:33
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;

if (!$ARGV[0]) {
    print STDERR "Missing argument: number of students in class.\n";
    exit (1);
}

my $attendance = $ARGV[0];

my $weekday = (localtime(time))[6];
my @daynames = ( 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
my %classes = (
    'Wed' => '0900 teaching Yoga Foundations at Lahara \(NN\) to 1000',
);


my $class = $classes{$daynames[$weekday]} || die ("No class defined for today.");
my $command = "llg " . $class;
$command =~ s/NN/$attendance/;

exec ($command);
