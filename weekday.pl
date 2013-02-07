#!/usr/bin/env perl

# weekday
# 2012-10-29 20:06
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;

my $file = $ARGV[0] or die ("No file.");

$file =~ s/\~/$ENV{'HOME'}/;

open (FILE, "<", $file) or die ("Cannot open file `$file': $!");
my @lines = <FILE>;
close (FILE);

foreach (@lines) {
    $_ =~ s/^[A-Za-z]+?day:\s?//;
}

my $weekday = (localtime (time))[6];
print $lines[$weekday];

exit (0);

__END__

=head1 NAME

weekday - predefined output for given day of the week

=head1 VERSION

1.0

=head1 SYNOPSIS

weekday [FILE]

=head1 DESCRIPTION

When passed a file containing a list of values for each weekday, ordered from
Sunday to Saturday, returns the value defined for the current day of the week.
If no file is passed, the result is an error.

=head1 AUTHOR

Written by Ian D. Brunton

=head1 REPORTING BUGS

Report bugs to iandbrunton at gmail dot com

=cut
