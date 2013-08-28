#!/usr/bin/env perl

# library.pl
# 2013-7-22 15:02
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;

my @records;
my @fields = (
    'author',
    'title',
    'location',
    'publisher',
    'year',
    'subtitle',
    'editor',
    'translator',
    'keywords',
);

my $record;
my $tabs;
my $library_dir = $ENV{HOME} . "/Dropbox/docs/library/";
my $record_file = "books.bib";

print "What bib file do you wish to use? ";

my $answer = <>;
chomp ($answer);

if ($answer) {
    if ($answer !~ /\.bib$/) {
    	$answer .= '.bib';
    }
    $record_file = $answer;
}
print "Using file `$library_dir$record_file'\n\n";

while ($answer !~ m/^no?/i) {
    push (@records, get_record (\@fields));
    print "Enter another record? (y/n) ";
    $answer = <>;
}

open (FILE, ">>", $library_dir . $record_file) or die ("Cannot open $record_file: $!");

my $keysource = 'author';
for (my $i = 0; $i <= $#records; $i++) {
    if (!$records[$i]->{author}) {
    	if ($records[$i]->{editor}) {
    	    $keysource = 'editor';
    	}
    	elsif ($records[$i]->{translator}) {
    	    $keysource = 'translator';
    	}
    	else {
    	    $keysource = 'title';
    	}
    }
    print FILE '@book {', lc (make_key ($records[$i]->{$keysource})), $records[$i]->{year}, ",\n";
    foreach (@fields) {
    	next if $records[$i]->{$_} eq '';
    	$tabs = "\t";
    	if (length ($_) < 8) { $tabs .= "\t"; }
    	print FILE "\t", $_, $tabs, "= {", $records[$i]->{$_}, "},\n";
    }
    print FILE "\thowpublished\t= {Print}\n}\n\n";
}

close (FILE);

###

sub get_record {
    my $fields = shift;
    my $input = {};
    foreach my $f (@fields) {
    	print ucfirst ($f), ': ';
    	$input->{$f} = <>;
    	$input->{$f} =~ s/\n//;
    }
    return $input;
}

sub make_key {
    my $keysource = shift;
    my ($first, $last) = split (/ ([^ ]+)$/, $keysource);
    return $last;
}

