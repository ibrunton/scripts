#!/usr/bin/env perl

use Modern::Perl;
use Log;

my $input = join( ' ', @ARGV );

my $log = Log->new;
$log->getopts( 'ajt', \$input );
$log->parse_rc;

my $action = $log->{editor} // $ENV{EDITOR} // '/usr/bin/env vim';
my $alternate = 'emacsclient';

# opt 'a' does something different from other log scripts:
if ( $log->opt( 'a' ) ) { $action = $alternate; }

$log->parse_datetime( \$input );

my $file = $log->file_path;
if ( -e $file ) {
    $action .= " $file";
    exec( $action );
}
else { print "File `$file' does not exist.\n"; }
