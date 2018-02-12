#!/usr/bin/env perl

# calprint
# 2018-02-04 12:00
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;
use IDB;
use DateTime;
use OpenOffice::OODoc;

my $month;
my $year;
my @wkdays = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
my @wkds = ('Sun', 'Mon', 'Tues', 'Wed', 'Thu', 'Fri', 'Sat');

my $console = 0;
my $formatted = 1;

my $dt = DateTime->new (
    time_zone => 'Canada/Atlantic',
    day       => 1,
    year      => 2018,
);

# parse input.
if (@ARGV) {
    foreach (@ARGV) {
	if ($_ =~ /\d{4}/) {
	    $year = $_;
	    $dt->set_year ($_);
	}
	elsif ($_ =~ /\d{2}/) {
	    $month = $_;
	    $dt->set_month ($_);
	}
	elsif ($_ eq '-c') {
	    $console = 1;
	    $formatted = 0;
	}
	elsif ($_ eq '-f') {
	    $console = 0;
	    $formatted = 1;
	}
    }
}
else {
    $dt = DateTime->now;
}

$year = $dt->year;
$month = $dt->month;

if ($console) {
    print $dt->month_name, ' ', $year, "\n";

    # 2nd row: 7 cells, weekdays
    for (my $i = 0; $i < 7; $i++) {
    	print "\t", $wkds[$i];
    }
    print "\n";

    # start first row, blank cells, square

    WEEK:
    for (my $i = 0; $i < 6; $i++) {
    	DAY:
    	for (my $d = 0; $d < 7; $d++) {
	    print "\t";
	    if ($dt->day == 1) {
	    	if ($dt->day_name ne $wkdays[$d]) {
		    next DAY;
	    	}
	    }
	    print $dt->day;
	    if ($dt->day < $dt->month_length) {
	    	$dt->add (days => 1);
	    }
	    else {
	    	last WEEK;
	    }
    	}
    	print "\n";
    }
    print "\n";
}

if ($formatted) {
    my $dir = '/home/ian/docs/programming/perl/calprint/';
    my $template = $dir . 'template.odt';
    my $output_file = $dir . $year . '-' . &IDB::double_digit ($month) . '.odt';

    my $oofile = odfContainer ($template);
    my $doc = odfDocument (
	container => $oofile,
	part => 'content'
    );

    my $t = $doc->getTableByName ('Table1');
    $doc->replaceText ($t, "MONTH", $dt->month_name);
    $doc->replaceText ($t, "YEAR", $year);

    $t = $doc->getTableByName ('Table2');

    my @rows = $doc->getTableRows ($t);
    WEEK:
    for (my $r = 1; $r < $#rows; $r++) {
	DAY:
	for (my $d = 0; $d < 7; $d++) {
	    if ($dt->day == 1) {
		if ($dt->day_name ne $wkdays[$d]) {
		    next DAY;
		}
	    }
	    $doc->updateCell ($t, $r, $d, $dt->day);
	    if ($dt->day < $dt->month_length) {
		$dt->add (days => 1);
	    }
	    else {
		if ($r < $#rows) {
		    $doc->deleteRow ($t, ++$r);
		}
		last WEEK;
	    }
	}
    }

    $oofile->save ($output_file);
}

exit (0);
