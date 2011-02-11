#!/usr/bin/env perl

use Modern::Perl;
use Pod::Usage;

use Log;

my $VERSION = '2.0';

my $log = Log->new();

my $input = join( ' ', @ARGV );

$log->getopts( 'efhjst', \$input ); #&getopts( 'fhjst', \%{$log->{opt}} ); #$log->process_options;

if ( $log->opt( 'h' ) ) { pod2usage( -exitstatus => 0, -verbose => 2 ); }

#print $input, "\n";

# uncomment these lines of you want to use them:
$log->parse_rc;
#$log->parse_state;

$log->parse_datetime( \$input ); # pass by reference so method can modify $input

my $file_path = $log->file_path;

if ( ! -e $file_path && ! $log->opt( 'f' ) ) {
    print "File $file_path does not exist.\n\n";
    exit( 0 );
}

if ( $log->opt( 'f' ) ) { print $file_path; exit 0; }

open( FILE, $file_path ) or die( "Can't open file $file_path: $!" );
while ( my $file_line = <FILE> ) {
    $log->replace_tags( \$file_line );
    print $file_line;
}
close( FILE );
print "\n";
exit( 0 );

__END__

=head1 NAME

clog - command-line log/journal printing

=head1 VERSION

2.0

=head1 SYNOPSIS

 clog [OPTIONS] [YYYY/MM/DD] [diff]
 clog 10/03
 clog -j 06 n1

=head1 DESCRIPTION

B<This program> facillitates outputs log files as written by the log
script. See that script's documentation for date formatting. With no
arguments, clog outputs today's log file, replacing tags with colour
codes. If the file pointed to (based optionally on -j and -t flags)
does not exist, and the -f flag has not been set, clog will return an
error message.

=head1 OPTIONS

=over 8

=item B<-f>

Outputs only the file path of the log, which can then be passed to a
script or program. This will return a valid path even if the file does
not exist.

=item B<-h>

Prints this documentation.

=item B<-j>

Points clog to the journal file rather than the main log file.

=item B<-s>

I don't know what this was meant to do yet.

=item B<-t>

Points clog to the training file rather than the main log file.

=back

=head1 AUTHOR

Written by Ian D. Brunton

=head1 REPORTING BUGS

Report Log bugs to ibrunton@accesswave.ca

=head1 COPYRIGHT

Copyright 2011 Ian Brunton.

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
