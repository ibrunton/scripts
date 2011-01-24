#!/usr/bin/env perl

use Modern::Perl;
use Pod::Usage;
use Text::Wrap;

use Log;

my $VERSION = '2.0';

if ( ! $ARGV[0] ) { pod2usage( -exitval => 1, -verbose => 1 ); }

my $log = Log->new();

my $input = join( ' ', @ARGV );

$log->getopts( 'acehijnqrstTw', \$input );

if ( $log->opt( 'h' ) ) { pod2usage( -exitstatus => 0, -verbose => 2 ); }

# uncomment these lines of you want to use them:
#$log->parse_rc_file;
#$log->parse_state;

$Text::Wrap::columns = $log->line_length;

$log->parse_datetime( \$input ); # pass by reference so method can modify $input

if ( ! -e $log->log_dir . $log->year ) {
    mkdir $log->log_dir . $log->year;
}
if ( ! -e $log->log_dir . $log->year . '/' . $log->month ) {
    mkdir $log->log_dir . $log->year . '/' . $log->month;
}

my $output = '';
my $comment = '';

# split input on -c or comment_char...
$input =~ s/(?<=\W)-c(\s)/ $log->comment_char.$1/eo;

my $cc = $log->comment_char;
if ( $input =~ m/$cc/ ) {
    ( $output, $comment ) = split( /$cc/, $input );
    $comment = $cc . $comment;
}
else { $output = $input; }

if ( $log->opt( 'c' ) ) {
    $comment = $log->indent_char . $input;
    $output = '';
    $log->set_opt( 'T' );
}

# expand snippets...
$output =~ s/:(\w+)/&expand($1,$log)/egi;

# text replacement...
if ( $output =~ m| -s([/#]).+?\1.*?\1| ) {
    print ">>Replacing...\n";
    my @seds;
    my $match;

    while ( $output =~ s| -s([/#])(.+?\1.*?\1)|| ) {
	$match = $1 . $2;
	push( @seds, $match );
	$output =~ s/$match//g;
    }

    my ( $r1, $r2 );
    foreach my $sed ( @seds ) {
	if ( $sed =~ m|^([/#])(.+?)\1(.*?)\1$| ) {
	    $r1 = $2;
	    $r2 = $3;
	    print ">>\t'$r1' with '$r2'...\n";
	    $output =~ s/$r1/$r2/eg;
	}
    }
}

# add time...
if ( $log->opt( 'n' ) ) {
    $output .= ' to ' . $log->time;
}
if ( $log->opt( 'i' ) ) {
    $output = "\t" . $output;
}

unless ( $log->opt( 'T' ) ) {
    $output = $log->time . ":\t" . $output;
}

# wrap...
unless ( $log->opt( 'w' ) ) {
    $output = wrap( "", $log->indent_char, $output );

    # make sure that if a comment begins partway through a line and wraps,
    # it will wrap at the right place:
    my @output_lines = split( /\n/, $output );
    my $len = $log->line_length - length( $output_lines[$#output_lines] ) - 8;
    my $short = '';
    if ( $len > 0 && length( $comment ) > 0 ) {
	if ( $comment =~ /^(;; .{1,$len})(\b | \b)/ ) {
	    $short = $1;
	    $comment =~ s/$short//o;
	    $comment =~ s/^ //o;
	}
	$output .= $short . "\n";
    }

    $comment = wrap( $log->comment_char . "\t", $log->comment_char . "\t", $comment );
}

my $file = $log->file_path;
open( FILE, ">>$file" ) or die( "Can't open file " . $file . ": $!" );

if ( $log->is_new ) { print FILE $log->date_string, "\n\n"; }

my $date = $log->date;
if ( $log->opt( 'j' ) ) {
    if ( $log->is_new ) { system( "log -cw " . $log->date . " JOURNAL FILE CREATED " . '-' x 41 ); }
    print FILE $log->comment_char . "\t" . $log->time . "\t" . '-' x 53 . "\n";
}
elsif ( $log->opt( 't' ) && $log->is_new ) {
    system( "log -cw ". $log->date . " TRAINING FILE CREATED " . '-' x 40 );
    print FILE "training\n\n";
}

print FILE $output . $comment . $log->end_of_line or die( "didn't print: $!" );

close( FILE );

# parse tags with colour codes and print to terminal:
unless ( $log->opt( 'q' ) ) {
    $log->replace_tags( \$output );
    $log->replace_tags( \$comment );
    print $output, $comment, $log->end_of_line;
}

if ( $log->opt( 'e' ) || $log->is_new ) {
    open( FILE, "<$file" ) or die( "Can't open file $file: $!" );
    while ( my $file_line = <FILE> ) {
	$log->replace_tags( \$file_line );
	print $file_line;
    }
    close( FILE );
    print "\n";
}

exit( 0 );

sub expand {
    my $snippet = shift;
    my $logref = shift;

    my $snippet_file = $logref->snippet_dir . $snippet;
    if ( -e $snippet_file ) {
	open( SNIPPET, "<$snippet_file" ) || die( "Cannot open file $snippet_file: $!\n" );
	my @file_contents = <SNIPPET>;
	close( SNIPPET );
	my $str = join( "", @file_contents );
	$str =~ s/\n$//so; # chop \n off the end
	return $str;

    }
    else { return $snippet; }
}

__END__

=head1 NAME

log - command-line log/journal processing

=head1 VERSION

2.0

=head1 SYNOPSIS

 log [OPTIONS] [YYYY/MM/DD] [TIME] [TEXT]
 log 10/03 1201 lunch
 log -n :std_nap_string -c very refreshing

=head1 DESCRIPTION

B<This program> facillitates keeping flat-file journals via the command
line.

=head2 DATES

If no date is passed, log will use the current date. To add to the log
of a different date, past or future, you can pass the full date in the
format YYYY/MM/DD; or only MM/DD and the current year will be used; or
only DD and the current year and month will be used.

You may also specify a date differential, which will be I<subtracted>
from the current date (or the date specified in the above format).
This takes the format B<n>I<N>, where N is any integer (and n is a
literal n).

The date and date differential, if specified, must be the first
arguments passed after input flags.

=head2 TIME

The time of the current entry is automatically generated by the script,
unless cancelled by one of the input flags (-c, -i, -T ), or unless a
different time is passed in the format HHMM. It is always 24-hour time.

The -r flag rounds the time to the nearest five minutes.

Time is ordinarily prepended to the line, followed by a colon and tab
("\t") character. You may optionally follow the time with a "~" or "?"
to indicate approximate or uncertain timing.

The -n flag appends the time to the end of the entry, rather than the
beginning.

=head2 SNIPPETS

Commonly used entries, or parts of entries, may be reused. Place the
frequently used text in a file in the snippet_dir (see B<Configuration
options> below, and type B<:snippet_name> on the command line. The
script will replace B<:snippet_name> with the contents of the file
with that name.

Snippets are not recursive; snippet names within snippets will not be
expanded. This functionality may be added to future versions.

=head2 TAGS

Tags...

=head2 COMMENTS

Comments may be added to the log file. To do so, either place the -c
flag as the first argument, in which case the whole entry will be
written as a comment, preceded by the comment delimiter (which can
be specified in the rc file), or else you may place the comment
delimiter itself, or -c, anywhere within the line of input, in which
case all text from that point forward will be a comment, without
a line break before it.

=head2 REPLACING TEXT

If you use snippets but occasionally wish to modify the text within
them on a case-by-case basis, use the snippet as usual and then add
a substitution macro to the input. This takes the form of
B<-s/original/replacement/> or B<-s#original#replacement#>. You may
specify as many such macros within a line of input as you wish; each
replacement will be performed as many times as possible on the input.

=head1 OPTIONS

=over 8

=item B<-a>

Cancels the automatic appendage of a newline to the input passed.

=item B<-c>

Treats the whole line (or anything after B<-c>, which may occur at any
point in a line) as a comment. B<-c> will be replaced with B<;;>.

=item B<-e>

Deprecated. Outputs the log file. For this functionality see the
B<clog> script included with this file.

=item B<-h>

Prints this help message.

=item B<-i>

Indents the line with a tab character.

=item B<-j>

Writes input to a file named YYYY/MM/DD.journal. Useful for longer
diary-type entries. A notation is added to the main log file to
indicate the presence of a journal entry.

=item B<-n>

Appends the current time to the end of the input line, rather than
placing it at the beginning.

=item B<-q>

Suppresses automatic echoing of the current input line.

=item B<-r>

Rounds the time to the nearest 5 minutes.

=item B<-R>

Cancels previously set rounding.

=item B<-s>

Does something to do with state.

=item B<-t>

Indicates that this input line is for the training log, rather than
the main log file. Input will be written to a file whose name ends in
F<.training>.

=item B<-T>

The current time will not be added to this line.

=item B<-w>

The current input line will not be wrapped. Useful for snippets which
are pre-formatted.

=back

=head1 CONFIGURATION OPTIONS

These options can be placed in F<~/.logrc>, to be read when log starts.

=over 8

=item B<auto_round>

Automatically round time values to nearest 5 minutes. Default: 0 (false).

=item B<log_dir>

The base directory in which log files will be written. Default: F<~/docs/log>.

=item B<log_snippet_dir>

The directory in which snippet files are kept. Default: F<log_dir/.snippets>.

=item B<training_extension>

The extension to be added to training log files. Default: F<.training>

=item B<journal_extension>

The extension to be added to journal files. Default: F<.journal>

=back

=head1 AUTHOR

Written by Ian D. Brunton

=head1 REPORTING BUGS

Report Log bugs to wolfshift@gmail.com

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
