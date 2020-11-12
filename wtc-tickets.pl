#!/usr/bin/env perl

# scripts
# 2017-08-23 10:16
# by Ian D Brunton <iandbrunton at gmail dawt com>
#
# NOTE: currently, this script must be run with PWD=$HOME/docs/theatre/
# cd into that directory and pass ONLY the filename, not the full path.

use Glib;
use Modern::Perl;
use OpenOffice::OODoc;

my $templatefile = $ENV{HOME} . '/Dropbox/templates/wtc-tickets.odt';
my $outputdir = $ENV{HOME} . '/docs/theatre/';

my $inputfile = $ARGV[0] || die ("No input file specified.");
my $details = &get_show_info ($inputfile);

#  debugging
my $go = 1;
#foreach my $k (sort keys %{$details->{dates}}) { print "$k => ", $details->{dates}->{$k}, "\n"; }


if ($go == 1) {
    foreach my $d (sort keys %{$details->{dates}}) {
    	my $oofile = odfContainer ($templatefile);
    	my $doc = odfDocument (
    	    container => $oofile,
    	    part => 'content'
    	);

    	my $t = $doc->getTableByName ('Table1');

    	my $open;
    	if ($details->{dates}->{$d} =~ m/7:00 PM/) {
	    $open = '6:30 PM';
    	}
    	elsif ($details->{dates}->{$d} =~ m/2:00 PM/) {
	    $open = '1:30 PM';
    	}

    	my @rows = $doc->getTableRows ($t);

    	foreach my $r (@rows) {
	    my @cells = $doc->getRowCells ($r);

	    foreach my $c (@cells) {
	    	$doc->replaceText ($c, "--TITLE--", $details->{title});
	    	$doc->replaceText ($c, "--DATE--", $details->{dates}->{$d});
	    	$doc->replaceText ($c, "--OPEN--", $open);
	    }
    	}

    	my $outputfile = $outputdir . $inputfile . '-' .  $d . '.odt';
    	$oofile->save ($outputfile);
    }
}

exit (0);

sub get_show_info {
    my $file = shift;

    my $hash = {};
    my $keyfile = Glib::KeyFile->new;
    $keyfile->load_from_file ($file, 'keep_comments');

    my $g = 'ticket';
    if ($keyfile->has_group ($g)) {
	if ($keyfile->has_key ($g, 'author')) {
	    $hash->{author} = $keyfile->get_string ($g, 'author');
	}
	if ($keyfile->has_key ($g, 'title')) {
	    $hash->{title} = $keyfile->get_string ($g, 'title');
	}
    }

    $hash->{run_length} = 0;
    $g = 'dates';
    if ($keyfile->has_group ($g)) {
	my @dates = $keyfile->get_keys ($g);

	foreach my $date (@dates) {
	    # my $s = $keyfile->get_string ($g, $date);
	    # my ($d, $t) = split (/;/, $s);
	    # $hash->{dates}->{$date}->{date} = $d;
	    # $hash->{dates}->{$date}->{time} = $t;
	    $hash->{dates}->{$date} = $keyfile->get_string ($g, $date);
	    ++$hash->{run_length};
	}
    }

    return $hash;

}
