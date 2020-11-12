#!/usr/bin/env perl

# scripts
# 2019-06-14 06:27
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;

my $file = shift (@ARGV);
my $newext = shift (@ARGV);

$file =~ s/\.[A-Za-z]+?$/\.$newext/;

print $file, "\n";

exit (0);
