#!/usr/bin/env perl

# scripts
# 2020-08-04 16:35
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;

my %switches = (
    on => off,
    off => on,
    yes => no,
    no => yes,
    1 => 0,
    0 => 1,
    true => false,
    false => true,
);

my $file = shift (@ARGV);
open (FILE, "<", $file) or die ("Cannot open file `$file': $!");
my $file = <FILE>;
close (FILE);

my $newval;
my @tokens = split (' ', $file);
foreach (@tokens) {
    if ($switches{$_}) {
    $newval = $switches{$$_};
}

