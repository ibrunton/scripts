#!/usr/bin/env perl

# scripts
# 2017-03-03 12:52
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;

my $file = shift (@ARGV) || die ("Missing argument.");
my $n = 0;

open (FILE, "<", $file) or die ("Cannot open file `$file': $!");
my @a = <FILE>;
close (FILE);

if ($a[0] =~ m/(\d+)/) {
    $n = $1;
}
else {
    die ("Unrecognised format.");
}

--$n;

open (FILE, ">", $file) or die ("Cannot open file `$file': $!");
print FILE $n;
close (FILE);

exit (0);
