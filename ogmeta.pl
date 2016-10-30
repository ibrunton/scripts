#!/usr/bin/env perl

# scripts
# 2016-10-30 10:42
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;

my $input_file;
my $dir = $ENV{HOME} . '/music/';
my $subdir;
my $output_file;

my %metadata;

if ($ARGV[0]) { $input_file = shift (@ARGV); }
else {
    print 'Enter input file: ';
    my $f = <STDIN>;
    $f =~ s/\n//;
    if (! -e $f) { die "File $f does not exist."; }
    else { $input_file = $f; }
}


print 'Enter output file name: ';
my $f = <STDIN>;
$f =~ s/\n//;
$output_file = $f;

if (-e $output_file) {
}

if ($output_file =~ m/^(\w+)\//) {
    $subdir = $1;
}

print 'Enter artist name: ';
my $c = <STDIN>;
$c =~ s/\n//;
$metadata{artist} = $c;

print 'Enter album artist (leave blank to copy artist name): ';
$c = <STDIN>;
$c =~ s/\n//;
$metadata{album_artist} = $c;
if ($metadata{album_artist} !~ m/\w/) {
    $metadata{album_artist} = $metadata{artist};
}

print 'Enter album title: ';
$c = <STDIN>;
$c =~ s/\n//;
$metadata{album} = $c;

print 'Enter track title: ';
$c = <STDIN>;
$c =~ s/\n//;
$metadata{title} = $c;

my $cmd = 'ffmpeg -i ' . $input_file . ' -metadata artist="' . $metadata{artist}
    . '" -metadata album_artist="' . $metadata{album_artist}
    . '" -metadata album="' . $metadata{album}
    . '" -metadata title="' . $metadata{title}
    . '" ' . $dir . $output_file;

my $ocmd = $cmd;
$ocmd =~ s/" /"\n /g;

print "\n", $ocmd, "\n\nWrite metadata? (y/n) ";

$c = <STDIN>;
if ($c =~ m/^[Yy]/) {
    exec ("$cmd");
}

exit (0);
