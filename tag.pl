#!/usr/bin/env perl

# log2
# 2011-12-31 11:14
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;
use Pod::Usage;
use Log;

my $VERSION = '1.0.1';

#if (! $ARGV[0]) { pod2usage (-exitval => 1, -verbose => 1); }

my $log = Log->new ();

$log->parse_rc;

my $input = join (' ', @ARGV);
$log->getopts ('hl', \$input);

if ($log->opt ('h')) {
    pod2usage (-exitstatus => 0, -verbose => 2);
}

# because I often miss the - when intending -l
if ($input =~ /(\bl\b)/) {
    $input =~ s/$1//;
    $log->set_opt ('l');
}

$log->parse_datetime (\$input);
my $tag_file = $log->log_dir . 'tags';

my $used_tags;
if (-e $tag_file) {
    open (TAGFILE, "<", $tag_file) or die ("Cannot open tag file: $!");
    my @tags = <TAGFILE>;
    close (TAGFILE);

    foreach (@tags) {
	$_ =~ s/\n//;
	if ($_ =~ m/^(\#[\w-]+)\t(\d+)$/) {
	    $used_tags->{$1} = $2;
	}
	else { next; }
    }
}

if ($input) {
    $input =~ s/\n//;

    my @newtags = split (/ /, lc ($input));
    foreach (@newtags) {
	$_ = '#' . $_;
    }

    my $logfile = $log->file_path;
    open (LOGFILE, "<", $logfile) or die ("Cannot open log file: $!");
    my @lines = <LOGFILE>;
    close (LOGFILE);

    # check for duplicates:
    foreach (@newtags) {
	if ($lines[2] =~ m/$_/) {
	    my $nt = join (' ', @newtags);
	    $nt =~ s/$_//;
	    @newtags = split (/ /, $nt);
	}
    }

    if ($#newtags >= 0) {	# still new tags left after removing duplicates
    	foreach (@newtags) {
	    $used_tags->{$_} += 1;
    	}

    	open (TAGFILE, ">", $tag_file) or die ("Cannot open tag file: $!");
    	foreach (sort keys %{$used_tags}) {
	    print TAGFILE $_, "\t", $used_tags->{$_}, "\n";
    	}
    	close (TAGFILE);
       
    	if ($lines[2] =~ m/^(\#[-a-z]+ ?){1,}$/) {
	    $lines[2] =~ s/\n//;
	    $lines[2] .= ' ' . join (' ', @newtags) . "\n";
    	} else {
	    splice (@lines, 2, 0, join (' ', @newtags), "\n\n");
    	}

    	open (LOGFILE, ">", $logfile) or die ("Cannot open log file: $!");
    	foreach (@lines) {
	    print LOGFILE $_;
    	}
    	close (LOGFILE);
    }
} elsif ($log->opt ('l')) {	# list all used tags, from most to least often used
    my $tag; my $count;
    format STDOUT = 
@<<<<<<<<<<<<<<<<<<<< @>>>>
$tag,            $count
.
    foreach (sort {$used_tags->{$b} <=> $used_tags->{$a}} keys %{$used_tags}) { 
	$tag = $_;
	$count = $used_tags->{$_};
	write;
    }
} else {			# just return tags for given date
    my $tags_printed = 0;
    open (FILE, "<", $log->file_path) or die ("Cannot open log file: $!");
    my @lines = <FILE>;
    close (FILE);

    if ($lines[0] =~ m/^\w+, \d{2} \w+, \d{4}$/) {
	print $log->date_markup ($lines[0]);
    }
		
    if ($lines[2] =~ m/^(\#[-a-z]+ ?){1,}$/) {
	print $log->comment_markup ($lines[2]);
    } else {
	say "No tags"
    }
}
