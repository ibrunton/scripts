#!/usr/bin/env perl

use Modern::Perl;

my $file = $ENV{HOME} . '/Dropbox/docs/avypp';

open (FILE, "<", $file) or die ("Cannot open $file: $!");
my $c = <FILE>;
close (FILE);

my ($used, $total) = ($c =~ m/(\d+)\/(\d+)/);

++$used;

open (FILE, ">", $file) or die ("Cannot open $file: $!");
print FILE "$used/$total\n";
close (FILE);

print "$used\/$total\n";

exit (0);
