#!/usr/bin/env perl

use Modern::Perl;
use Pod::Usage;
use Log;

my $VERSION = '1.0';

if ( ! $ARGV[0] ) { pod2usage( -exitval => 1, -verbose => 1 ); }

my $log = Log->new();

my $input = join( ' ', @ARGV );

$log->getopts( 'hinrT', \$input );

if ( $log->opt( 'h' ) ) { pod2usage( -exitstatus => 0, -verbose => 2 ); }

# uncomment these lines of you want to use them:
#$log->parse_rc_file;
#$log->parse_state;

$log->parse_datetime( \$input ); # pass by reference so method can modify $input

__END__

=head1 NAME

logstate - saves information to send to log later

=head1 SYNOPSIS

logstate [OPTIONS] [DATE] [TIME] [TEXT]

=head1 DESCRIPTION

logstate is used to store information for a log entry without yet writing it to
the log file. If passed the time, it will store the time, to be retrieved later
and used for the next log entry; if passed an entry, it will be stored until
later, and snippets will not be expanded; if passed options, those options will
be stored and used upon retrieval.

See POD for main log script for information on options, snippets, date and time
formats, and text replacement.

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
