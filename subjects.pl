#!/usr/bin/env perl

# 2012-04-16 09:41
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;
use XML::Simple;
use IDB;

my $home = $ENV{HOME};

my $username = $ARGV[0];
my $filename = "$home/.local/share/inbox_$username";

my $xml = new XML::Simple;
my $inbox = $xml->XMLin ($filename);
my @amodtime = localtime ((stat ($filename))[9]);
my $modtime = join (' ', join ('-', $amodtime[5] + 1900,
	&IDB::double_digit ($amodtime[4]), &IDB::double_digit ($amodtime[3])),
    ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')[$amodtime[6]],
    join (':', &IDB::double_digit ($amodtime[2]), &IDB::double_digit ($amodtime[1])));

#$inbox->{modified} =~ s/[TZ]/ /g;

print "Messages for $username: ", $inbox->{fullcount}, "\n";
#print "at ", $inbox->{modified}, "\n\n";
print "$modtime\n\n";

if ($inbox->{fullcount} > 0) {
	if ($inbox->{fullcount} > 1) {
		foreach my $msg (keys %{$inbox->{entry}}) {
			print "  From: ", $inbox->{entry}->{$msg}->{author}->{name}, " ";
			print "<", $inbox->{entry}->{$msg}->{author}->{email}, ">\n";
			print "  Subject: ", $inbox->{entry}->{$msg}->{title}, "\n\n";
		}
	}
	else {
		print "  From: ", $inbox->{entry}->{author}->{name}, " ";
		print "<", $inbox->{entry}->{author}->{email}, ">\n";
		print "  Subject: ", $inbox->{entry}->{title}, "\n\n";
	}
}

exit (0);
