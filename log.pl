#!/usr/bin/env perl

use Modern::Perl;
use Pod::Usage;
use Text::Wrap;

use Log;

my $VERSION = '2.2.7';

if ( ! $ARGV[0] ) { pod2usage( -exitval => 1, -verbose => 1 ); }

my $log = Log->new();

$log->parse_rc;

my $input = join( ' ', @ARGV );

$log->getopts( 'abcehijnpqrstw', \$input );

if ( $log->opt( 'h' ) ) { pod2usage( -exitstatus => 0, -verbose => 2 ); }

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

if ( $input eq '-') {
    $input = <STDIN>;
    chomp( $input );
}

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
    $log->set_opt( 't' );
}

# expand snippets...
while ($output =~ m/(?<!\w):([\/\w]+)/) {
    $output =~ s/(?<!\w):([\/\w]+)/&expand($1,$log)/egi;
}

# execute shell commands from within snippets:
if ($output =~ m/`(.+?)`/) {
    my $cmd = $1;
    my $cmdinput = `$cmd`;
    $cmdinput =~ s/\n$//;
    $output =~ s/`$cmd`/$cmdinput/;
}

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
    if ($output && $comment) {
	$output .= ' ';
    }
}
if ( $log->opt( 'i' ) ) {
    $output = "\t" . $output;
}

unless ( $log->opt( 't' ) ) {
    $output = $log->time . ":\t" . $output;
}

if ($log->opt ('p')) {
    $output = $log->predictor_char . $output;
}

# wrap...
unless ( $log->opt( 'w' ) ) {
    unless ( $log->opt('c') ) {
	$output = wrap( "", $log->indent_char, $output );
    }

    my $ic = $log->indent_char;
    # prevent orphaned single characters at end of entry:
    $output =~ s/\n$ic([^\s\n])$/ $1/;
    
    # make sure that if a comment begins partway through a line and wraps,
    # it will wrap at the right place:
    if ( length( $output ) > 1 && $comment ) {
	my @output_lines = split( /\n/, $output );
	my $len = $log->line_length - length( $output_lines[$#output_lines] ) - 8;
	my $short = '';
	if ( $len > 0 && length( $comment ) > $len ) {
	    if ( $comment =~ /^(;; .{1,$len})(\b | \b)/ ) {
		$short = $1;
		$comment =~ s/$short//o;
		$comment =~ s/^ //o;
		$output .= $short . "\n";
		if ( $comment !~ /^$cc\t/ ) {
		    $comment = $cc . "\t" . $comment;
		}
	    }
	}
    }
    
    $comment = wrap( "", $log->comment_char . "\t", $comment );

    # prevent orphaned single characters at end of comment:
    $comment =~ s/\n$cc\t([^\s\n])$/ $1/;
}

my $file = $log->file_path;
open( FILE, ">>$file" ) or die( "Can't open file " . $file . ": $!" );

if ( $log->is_new ) {
    print FILE $log->date_string, "\n\n";
    $log->unset_opt ('b');
}

# prepend blank line:
# (kind of cludgy)
if ($log->opt('b')) {
    if ($input eq '') { # if no other input, just insert a single blank line
	$log->{end_of_line} = '';
	$log->set_opt ('t');
	$output = "\n";
    }
    else { # blank line plus additional input
	$output = "\n" . $output;
    }
}

my $date = $log->date;

if ($log->{extension} ne '') {
    if ($log->is_new) {
	system ("log -cw " . $log->date . " " . uc ($log->{extension}) . " file created");
    }
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
	
	my $ic = $logref->indent_char;
	if ($str =~ s/#BR#/\n$ic/g) {
	    $logref->set_opt('w');
	}
	
	return $str;
    }
    else { return $snippet; }
}

__END__

=head1 NAME

log - command-line log/journal processing

=head1 VERSION

2.2.7

=head1 SYNOPSIS

 log [OPTIONS] [YYYY/MM/DD] [TIME] [TEXT]
 log 10/03 1201 lunch
 log -n :std_nap_string -c very refreshing

=head1 DESCRIPTION

B<This program> facillitates keeping flat-file journals via the command
line.

=head2 DATES

If no date is passed, log will use the current date.  To add to the log
of a different date, past or future, you can pass the full date in the
format YYYY/MM/DD; or only MM/DD and the current year will be used; or
only DD and the current year and month will be used.

You may also specify a date differential, which will be I<subtracted>
from the current date (or the date specified in the above format).
This takes the format B<->I<N>, where N is any integer.  It can be
specified anywhere with other -flag style options.

The date and date differential, if specified, must be the first
arguments passed after input flags.

=head2 TIME

The time of the current entry is automatically generated by the script,
unless cancelled by one of the input flags (-c, -i, -t ), or unless a
different time is passed in the format HHMM.  It is always 24-hour time.
If a colon is included (HH:MM), it is automatically removed.  The option
to retain the colon is planned for a future release.

The -r flag rounds the time to the nearest five minutes.

Time is ordinarily prepended to the line, followed by a colon and tab
("\t") character.  You may optionally follow the time with a "~" or "?"
to indicate approximate or uncertain timing.  A '[' may be prepended to
the time in order to indicate an anticipated event.

The -n flag appends the time to the end of the entry, rather than the
beginning.

=head2 SNIPPETS

Commonly used entries, or parts of entries, may be reused.  Place the
frequently used text in a file in the snippet_dir (see B<Configuration
options> below, and type B<:snippet_name> on the command line.  The
script will replace B<:snippet_name> with the contents of the file
with that name.

Snippets are recursive as of version 2.2.  Currently no checking is done
to prevent infinite recursion.  As of version 2.6, snippet files can be
organised into subdirectories and called on the command line as :dir/file .

As of v. 2.2.7, snippets may contain system calls.  Text between `backticks`
will be interpreted as a command to be passed to the system; its output will
be captured and inserted into log's output.  NB: NO FILTERING OR CHECKING
IS CURRENTLY PERFORMED ON SUCH SYSTEM COMMANDS.

=head2 TAGS

Tags are single-character labels defined in the configuration file in
order to allow the user (1) to mark content for easy finding with a
utility such as grep, and (2) to enable colour-coded terminal output.

Tags are marked by the '$' character, so when entering them from the
command line, this character must be escaped.

Tags can be upper case or lower case.  All text between a lower-case
tag (e.g., '$a') and a '$' not followed by a letter will be colour-coded.
An upper-case tag has no matching end-tag, and colour-codes everything
preceeding it on the line.  After an upper-case tag or the closing '$'
of a lower-case tag, the program sends an escape sequence to the terminal
to return to normal text.

Tags cannot span line breaks.

=head2 COMMENTS

Comments may be added to the log file.  To do so, either place the -c
flag as the first argument, in which case the whole entry will be
written as a comment, preceded by the comment delimiter (which can
be specified in the rc file), or else you may place the comment
delimiter itself, or -c, anywhere within the line of input, in which
case all text from that point forward will be a comment, without
a line break before it.

=head2 REPLACING TEXT

If you use snippets but occasionally wish to modify the text within
them on a case-by-case basis, use the snippet as usual and then add
a substitution macro to the input.  This takes the form of
B<-s/original/replacement/> or B<-s#original#replacement#>.  You may
specify as many such macros within a line of input as you wish; each
replacement will be performed as many times as possible on the input.
No regular expressions are evaluated.

=head1 OPTIONS

=over 8

=item B<-a>

Cancels the automatic appendage of a newline to the input passed.

=item B<-b>

Inserts a blank line.  If further input is passed, it is processed
normally and inserted after the blank line.

=item B<-c>

Treats the whole line (or anything after B<-c>, which may occur at any
point in a line) as a comment.  B<-c> will be replaced with the
string specified for denoting comments (default is B<;;>).

=item B<-e>

Deprecated.  Outputs the log file.  For this functionality see the
B<clog> script included with this file.

=item B<-h>

Prints this help message.

=item B<-i>

Indents the line with a tab character.

=item B<-n>

Appends the current time to the end of the input line, rather than
placing it at the beginning.

=item B<-p>

Prepends predictor_char to the time, to indicate that this time value
is anticipated in the future.

=item B<-q>

Suppresses automatic echoing of the current input line.

=item B<-r>

Rounds the time to the nearest 5 minutes.

=item B<-t>

The current time will not be added to this line.

=item B<-w>

The current input line will not be wrapped.  Useful for snippets which
are pre-formatted.

=back

=head1 CONFIGURATION OPTIONS

These options can be placed in F<~/.config/logrc>, to be read when log
starts.  The configuration file is a Glib key file, divided into sections.

=over 8

=item B<[log] section>

This section is required.

=over 8

=item B<log_dir>

The base directory in which log files will be written.  Default: F<~/docs/log>.

=item B<log_snippet_dir>

The directory in which snippet files are kept.  Default: F<log_dir/.snippets>.

=item B<editor>

The executable to use to edit log files using the I<editlog.pl> script.

=item B<alternate_editor>

Alternate editor, used when passing the -a option to the I<editlog.pl> script.

=item B<auto_round>

Automatically round time values to nearest 5 minutes.  Default: false.

=item B<auto_echo>

Automatically output the result of the log command to the console as well
as to the log file.  Default: true.

=item B<mark_rounded>

Append an indicator to time values when they are rounded.  If the -r option is
passed or auto_round is set and log is called when rounding would not change
the time value (i.e., the current time ends in 0 or 5), no indicator is
appended.  Default: false.

=item B<rounded_time_char>

The character appended to time values if mark_rounded is set to true.
Default: ~

=item B<comment_char>

The string used to mark comments.  Can be a single character or more.
Default: ;;

=item B<predictor_char>

The single character prepended to time values when the -p option is passed.
Default: [

=item B<line_length>

The number of characters per line, after which lines will be wrapped.
Default: 70

=back

=item B<[tags] section>

Here the user may define single-character tags to be used (1) to facilitate
searching log files with e.g. grep, and (2) to enable the use of colour-coding.
Each tag definition takes the form of the character that will be used to
represent it and the terminal escape sequence for the desired colour.

=item B<[extensions] section>

Here the user may define additional command-line options.  Each single-character
option is given a string that will be the file extension of the resulting log
entry.  This is useful for entering more detailed information that does not need
to be included in the main log file.

=back

=head1 AUTHOR

Written by Ian D. Brunton

=head1 REPORTING BUGS

Report Log bugs to iandbrunton at gmail.com

=head1 COPYRIGHT

Copyright 2011-2012 Ian Brunton.

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
