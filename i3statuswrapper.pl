#!/usr/bin/env perl
# vim:ts=4:sw=4:expandtab
# © 2012 Michael Stapelberg, Public Domain

# This script is a simple wrapper which prefixes each i3status line with custom
# information. To use it, ensure your ~/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in your ~/.i3/config, use:
#     status_command i3status | ~/i3status/contrib/wrapper.pl
# In the 'bar' section.

use strict;
use warnings;
# You can install the JSON module with 'cpan JSON' or by using your
# distribution’s package management system, for example apt-get install
# libjson-perl on Debian/Ubuntu.
use JSON;

# Don’t buffer any output.
$| = 1;

# Skip the first line which contains the version header.
print scalar <STDIN>;

# The second line contains the start of the infinite array.
print scalar <STDIN>;

# Read lines forever, ignore a comma at the beginning if it exists.
while (my ($statusline) = (<STDIN> =~ /^,?(.*)/)) {
    # Decode the JSON-encoded line.
    my @blocks = @{decode_json($statusline)};

    # Prefix our own information (you could also suffix or insert in the
    # middle).
    my $db = &get_dropbox_status;
    my $wmail = &get_wolfmail_count;
    my $imail = &get_ianmail_count;
    @blocks = ( 
        $db,
        $wmail,
        $imail,
        @blocks);

    # Output the line as JSON.
    print encode_json(\@blocks) . ",\n";
}

sub get_wolfmail_count {
    my $count;
    my $colour;

    my $highlight = '#4abcd4';
    my $neutral = '#e0e0e0';
    my $bad = '#cd5666';

    open(FILE, "<", '/home/ian/.local/share/mailcount_wolfshift') or die();
    $count = <FILE>;
    close(FILE);
    $count =~ s/\n//g;

    if ($count > 0) {
        $colour = $highlight;
    }
    elsif ($count < 0) {
        $colour = $bad;
    }
    else {
        $colour = $neutral;
    }

    my $obj = {
        full_text => 'Wolf: ' . $count,
        name => 'wolfmail',
        color => $colour
    };
    return $obj;
}

sub get_ianmail_count {
    my $count;
    my $colour;

    my $highlight = '#4abcd4';
    my $neutral = '#e0e0e0';
    my $bad = '#cd5666';

    open(FILE, "<", '/home/ian/.local/share/mailcount_iandbrunton') or die();
    $count = <FILE>;
    close(FILE);
    $count =~ s/\n//g;

    if ($count > 0) {
        $colour = $highlight;
    }
    elsif ($count < 0) {
        $colour = $bad;
    }
    else {
        $colour = $neutral;
    }

    my $obj = {
        full_text => 'Ian: ' . $count,
        name => 'ianmail'.
        color => $colour
    };
    return $obj;
}

sub get_last_update {
}

sub get_dropbox_status {
    my $active = '#4abcd4';
    my $idle = '#e0e0e0';
    my $bad = '#cd5666';

    my $colour;
    my $icon;

    my $status = `dropbox-cli status`;

    if ($status =~ /Uploading|Syncing/) {
        $colour = $active;
        $icon = 'Û';
    }
    elsif ($status =~ /Downloading/) {
        $colour = $active;
        $icon = 'Ú';
    }
    elsif ($status =~ /Indexing/) {
        $colour = $active;
        $icon = 'i';
    }
    elsif ($status =~ /Starting|Connecting|Initializing|Wait/) {
        $colour = $bad;
        $icon = 'Ð';
    }
    elsif ($status =~ /Idle|Up to date/) {
        $colour = $idle;
        $icon = 'Ñ';
    }
    elsif ($status =~ /Dropbox isn't connected/) {
        $colour = $bad;
        $icon = '§';
    }
    else {
        $colour = $bad;
        $icon = '?';
    }

    my $obj = {
        full_text => " $icon",
        name => 'dropbox',
        color => $colour
    };
    return $obj;
}
