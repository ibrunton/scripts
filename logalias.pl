#!/usr/bin/env perl

# logalias
# 2013-01-22 10:37
# by Ian D Brunton <iandbrunton at gmail dawt com>

# logalias -t TV: -- -1 Futurama

use Modern::Perl;

my $input = join (' ', @ARGV);
my $prefix = '';
my $opts = '';

$input =~ s/(["'])/\\$1/g;

if ($input =~ m/(.+) --/) {
    $prefix = $1;
    $input =~ s/$prefix//;
}

if ($input =~ m/ --(\s+-([\w\d]+)+)/) {
    $opts = $1;
    $input =~ s/$opts//;
}
$input =~ s/--//;

my $cmd = "$opts $prefix $input\n";
$cmd =~ s/^ //;
print "log $cmd";

exec ($ENV{HOME} . "/bin/llg $cmd");
