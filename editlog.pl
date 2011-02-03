#!/usr/bin/env perl

use Modern::Perl;
use Log;

my $action = $ENV{EDITOR} // '/usr/bin/env vim';
my $alternate = 'emacsclient';

my $input = join( ' ', @ARGV );

my $log = Log->new;
$log->getopts( 'ajt', \$input );

# opt 'a' does something different from other log scripts:
if ( $log->opt( 'a' ) ) { $action = $alternate; }

$log->parse_datetime( \$input );

my $file = $log->file_path;
if ( -e $file ) {
    $action .= " $file";
    exec( $action );
}
else { print "File `$file' does not exist.\n"; }
