#!/usr/bin/env perl

# 2012-04-16 09:41
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Modern::Perl;
use XML::Simple;

my $home = $ENV{HOME};

my $username = $ARGV[0];

my $xml = new XML::Simple;
my $inbox = $xml->XMLin ("$home/.local/share/inbox_$username");

$inbox->{modified} =~ s/[TZ]/ /g;

print "Messages for $username: ", $inbox->{fullcount}, "\n";
print "at ", $inbox->{modified}, "\n\n";

if ($inbox->{fullcount} > 0) {
	if ($inbox->{fullcount} > 1) {
		foreach my $msg (keys %{$inbox->{entry}}) {
			print "From: ", $inbox->{entry}->{$msg}->{author}->{name}, " ";
			print "<", $inbox->{entry}->{$msg}->{author}->{email}, ">\n";
			print "Subject: ", $inbox->{entry}->{$msg}->{title}, "\n\n";
		}
	}
	else {
		print "From: ", $inbox->{entry}->{author}->{name}, " ";
		print "<", $inbox->{entry}->{author}->{email}, ">\n";
		print "Subject: ", $inbox->{entry}->{title}, "\n\n";
	}
}

exit (0);
