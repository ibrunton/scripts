#!/usr/bin/env perl

use Modern::Perl;
use Pod::Usage;

use Log;

my $VERSION = '2.0';

my $log = Log->new();

my $input = join (' ', @ARGV);

$log->parse_rc;

$log->getopts ('dfhm', \$input);

if ($log->opt ('h')) {
    pod2usage (-exitstatus => 0, -verbose => 2);
}

$log->parse_datetime (\$input); # pass by reference so method can modify $input

my $file_path = $log->file_path;

if (! -e $file_path && ! $log->opt ('f')) {
    print "File $file_path does not exist.\n\n";
    exit (0);
}

if ($log->opt ('f')) {
    if ($log->opt ('d')) {
	print $log->{dir_path};
	exit 0;
    } else {
	print $file_path; exit 0;
    }
}

open (FILE, "<", $file_path) or die ("Can't open file $file_path: $!");
while (my $file_line = <FILE>) {
    $log->markup (\$file_line);
    print $file_line;
}
close (FILE);
print "\n";
exit (0);

__END__

=head1 NAME

clog - command-line log/journal printing

=head1 VERSION

2.0

=head1 SYNOPSIS

 clog [OPTIONS] [YYYY/MM/DD] [diff]
 clog 10/03
 clog -J 06 n1

=head1 DESCRIPTION

B<This program> outputs log files as written by the log script.  See that
script's documentation for date formatting.  With no arguments, clog outputs
today's log file, replacing tags with colour codes.  If the file pointed to
does not exist, and the -f flag has not been set, clog will return an error
message.

=head1 OPTIONS

=over 8

=item B<-d>

If B<-f> is also passed, prints the directory path to log files for
the current month, or the month specified by the date passed.

=item B<-f>

Outputs only the file path of the log, which can then be passed to a
script or program. This will return a valid path even if the file does
not exist.

=item B<-h>

Prints this documentation.

=item B<-m>

Suppresses coloured markup output.

=back

=head1 AUTHOR

Written by Ian D. Brunton

=head1 REPORTING BUGS

Report Log bugs to iandbrunton at gmail. com.

=head1 COPYRIGHT

Copyright 2011--13 Ian D. Brunton.

This file is part of Log.

Log is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Log is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Log.  If not, see <http://www.gnu.org/licenses/>.

=cut  
