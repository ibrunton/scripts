#!/usr/bin/env perl

# scripts
# 2017-03-20 13:52
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;

my $file = $ENV{HOME} . '/Dropbox/docs/todo';

if ($ARGV[0]) {
    my $prefix = '* ';
    if ($ARGV[0] eq '-p') {
	shift (@ARGV);
	$prefix = '!* ';
    }
    my $s = ucfirst (join (' ', @ARGV));
    open (FILE, ">>", $file) or die ("Cannot open file $file: $!");
    print FILE $prefix, $s, "\n";
    close (FILE);
}
else {
    exec ('vim ' . $file);
}

exit (0);
