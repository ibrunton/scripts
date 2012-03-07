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

if ($log->opt ('h')) { pod2usage (-exitstatus => 0, -verbose => 2); }

$log->parse_datetime (\$input);
my $tag_file = $log->log_dir . 'tags';

if ($input) {
	$input =~ s/\n//;

	my @newtags = split (/ /, lc ($input));
	foreach (@newtags) {
		$_ = '#' . $_;
	}

	if (-e $tag_file) {
		open (TAGFILE, $tag_file) or die ("Cannot open tag file: $!");
		my @tags = <TAGFILE>;
		close (TAGFILE);

		my $used_tags;
		foreach (@tags) {
			$_ =~ s/\n//;
			next if ($_ !~ m/^\#\w+$/);
			$used_tags->{$_} = 1;
		}

		my $rewrite_flag = 0;

		foreach (@newtags) {
			# ...check to see if new tag partially matches any existing tag,
			# prompt user whether to reuse existing tag; if so, replace $_

			unless ($used_tags->{$_}) {
				$rewrite_flag = 1;
				$used_tags->{$_} = 1;
			}
		}

		if ($rewrite_flag == 1) {
			open (TAGFILE, ">$tag_file") or die ("Cannot open tag file: $!");
			foreach (sort keys %{$used_tags}) {
				print TAGFILE $_, "\n";
			}
			close (TAGFILE);
		}
	} else {
		open (TAGFILE, ">$tag_file") or die ("Cannot open tag file: $!");
		print TAGFILE join ("\n", @newtags);
		close (TAGFILE)
	}

	my $logfile = $log->file_path;
	open (LOGFILE, $logfile) or die ("Cannot open log file: $!");
	my @lines = <LOGFILE>;
	close (LOGFILE);

	if ($lines[2] =~ m/^(\#\w+ ?){1,}$/) {
		$lines[2] =~ s/\n//;
		$lines[2] .= ' ' . join (' ', @newtags) . "\n";
	} else {
		splice (@lines, 2, 0, join (' ', @newtags), "\n\n");
	}

	open (LOGFILE, ">$logfile") or die ("Cannot open log file: $!");
	foreach (@lines) {
		print LOGFILE $_;
	}
	close (LOGFILE);

} elsif ($log->opt ('l')) { # list all used tags
	exec ("cat $tag_file");
} else { # just return tags for given date
	my $tags_printed = 0;
	open (FILE, $log->file_path) or die ("Cannot open log file: $!");
	my @lines = <FILE>;
	close (FILE);

	if ($lines[0] =~ m/^\w+, \d{2} \w+, \d{4}$/) {
		print $lines[0];
	}
		
	if ($lines[2] =~ m/^(\#\w+ ?){1,}$/) {
			print $lines[2];
	} else {
		say "No tags"
	}
}
