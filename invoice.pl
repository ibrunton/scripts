#!/usr/bin/env perl

# scripts
# 2017-07-18 13:39
# by Ian D Brunton <iandbrunton at gmail dawt com>

use Glib;
use Modern::Perl;
use Pod::Usage;
use File::Copy qw(move);
use OpenOffice::OODoc;
use IDB;

my $print_to_console = 0;
my $create_formatted = 0;
my $move_to_archive  = 0;
my $use_config       = 1;
my $debug            = 0;
my $opts             = {};

if (@ARGV) {
    for (my $i = 0; $i <= $#ARGV; ++$i) {
	if ($ARGV[$i] eq '-c') {
	    $print_to_console = 1;
	}
	elsif ($ARGV[$i] eq '-f') {
	    $create_formatted = 1;
	}
	elsif ($ARGV[$i] eq '-m') {
	    $move_to_archive = 1;
	}
	elsif ($ARGV[$i] eq '--type') {
	    $opts->{invoicee} = $ARGV[++$i];
	}
	elsif ($ARGV[$i] =~ m/--type=(\w+)/) {
	    $opts->{invoicee} = $1;
	    $use_config = 1;
	}
	else {
	    print "Unknown option: $ARGV[$i]\n";
	}
    }
}

if ($use_config) {
    &parse_rc_file ($opts);
}

open (FILE, "<", $opts->{payperiod_file}) or die ("Cannot open file `$opts->{payperiod_file}': $!");
my @records = <FILE>;
close (FILE);

# Create a string indicating the pay period
my $raw_period;
if ($records[0] =~ /^# \d{4}-\d{2}-\d{2}/) {
    $raw_period = shift (@records);
    $raw_period =~ s/^# //;
}
else {
    if ($records[0] =~ /^(\d{4}-\d{2}-\d{2})/) {
	$raw_period = $1;
    }
}

my ($py1, $pm1, $pd1) = ($raw_period =~ /^(\d{4})-(\d{2})-(\d{2})/);
my $period_string = $pd1 . ' ' . &IDB::mon ($pm1 - 1) . ' ' . $py1 . ' through ' . &IDB::shortdate;

# date
my $filedate = &IDB::filedate;
my $date = &IDB::nicedate;


# Sort the flat-file data into a useful hash
my $data = {};
foreach (@records) {
    my ($_date, $_client, $_ord, $_rate) =
    	($_ =~ /(\d{4}-\d{2}-\d{2} [SMTWF][a-z]{2})\t([A-Za-z ]+)\t(\d+\/\d+\+?)\t(\d+\.\d{2})/);
    $_rate = sprintf ("%.2f", $_rate);
    push (@{$data->{rates}->{$_rate}->{items}}, { client => $_client, date => $_date, number => $_ord });
    $data->{rates}->{$_rate}->{subtotal} += $_rate;
    $data->{total} += $_rate;
}

# force 2 decimal places
foreach (keys %{$data->{rates}}) {
    $data->{rates}->{$_}->{subtotal} = sprintf ("%.2f", $data->{rates}->{$_}->{subtotal});
}
$data->{total} = sprintf ("%.2f", $data->{total});

# print to console as text
if ($print_to_console) {
    print $date, "\n\n";
    print "Invoice for pay period $period_string\n\n";
    foreach my $_rate (sort keys %{$data->{rates}}) {
    	print $#{$data->{rates}->{$_rate}->{items}} + 1 . " sessions at $_rate:";
	print "\t\t\t\t\$ " . $data->{rates}->{$_rate}->{subtotal} . "\n";

    	for (my $i = 0; $i <= $#{$data->{rates}->{$_rate}->{items}}; ++$i) {
	    print "\t" . $data->{rates}->{$_rate}->{items}->[$i]->{date} .
		"\t" . $data->{rates}->{$_rate}->{items}->[$i]->{client} .
		"\t" . $data->{rates}->{$_rate}->{items}->[$i]->{number} .
		"\n";
    	}
	print "\n";
    }

    print "\nTotal:\t\t\t\t\t\t\$ " . $data->{total} . "\n\n";
}

#   Creates a formatted ODT file from a template
#   (It would be possible to have multiple options for different formats,
#   but that would require significantly more code for little return.)
if ($create_formatted) {
    my $invoice_num = &invoice_number ($opts);

    my $output_file = $opts->{invoice_dir} . $invoice_num . '_' . $filedate .
	'_' . $opts->{invoicee} . '.odt';

    my $oofile = odfContainer ($opts->{template_file});
    my $doc = odfDocument (
	container => $oofile,
	part => 'content'
    );

    my $t = $doc->getTableByName ('Table1');
    $doc->replaceText ($t, "--DATE--", $date);
    $doc->replaceText ($t, "--INVNUM--", $invoice_num);
    my $c = $doc->getCellValue ($t, -1, -1);
    print $c, "\n";

    $t = $doc->getTableByName ('Table2');
    $doc->replaceText ($t, "--PERIOD--", $period_string);

    $t = $doc->getTableByName ('Table3');

    my $row = 2;  # first row to modify
    foreach my $_rate (sort keys %{$data->{rates}}) {
	$doc->insertRow ($t, $row);
	$doc->updateCell ($t, $row, 0, $opts->{$_rate});
	$doc->updateCell ($t, $row, 1, $#{$data->{rates}->{$_rate}->{items}} + 1);
	$doc->updateCell ($t, $row, 2, $_rate);
	$doc->updateCell ($t, $row, 3, $data->{rates}->{$_rate}->{subtotal});

	for (my $i = 0; $i <= $#{$data->{rates}->{$_rate}->{items}}; ++$i) {
	    $doc->insertRow ($t, $row++, "position => after");
	    $doc->updateCell ($t, $row, 0, '    ' .
		$data->{rates}->{$_rate}->{items}->[$i]->{date} . ' ' .
		$data->{rates}->{$_rate}->{items}->[$i]->{client} . ' ' .
		$data->{rates}->{$_rate}->{items}->[$i]->{number}
	    );
	    $doc->updateCell ($t, $row, 1, '');	# make sure these cells are blank
	    $doc->updateCell ($t, $row, 2, '');
	    $doc->updateCell ($t, $row, 3, '');
	}
	$doc->insertRow ($t, $row++, "position => after");
	    $doc->updateCell ($t, $row, 0, '');
	    $doc->updateCell ($t, $row, 1, '');
	    $doc->updateCell ($t, $row, 2, '');
	    $doc->updateCell ($t, $row, 3, '');
	$doc->insertRow ($t, $row++, "position => after");
	    $doc->updateCell ($t, $row, 0, '');
	    $doc->updateCell ($t, $row, 1, '');
	    $doc->updateCell ($t, $row, 2, '');
	    $doc->updateCell ($t, $row, 3, '');
    }

    $doc->updateCell ($t, -1, -1, $data->{total});

    $oofile->save ($output_file);
}

if ($move_to_archive) {
    my $archivefile = $opts->{archive_dir} . $filedate . '_' . $opts->{invoicee};
    move ($opts->{payperiod_file}, $archivefile);
}

exit (0);

sub invoice_number {
    my $f = $opts->{count_file};
    open (FILE, "<", $f) or die ("Cannot open file `$f': $!");
    my $l = <FILE>;
    close (FILE);

    my $n;

    if ($l =~ /(\d+)/) {
	$n = $1;
    }
    else { # error
    }

    ++$n;
    $n = sprintf ("%03d", $n);
    
    open (FILE, ">", $f) or die ("Cannot open file `$f': $!");
    print FILE $n;
    close (FILE);

    return $n;
}

sub parse_rc_file {	# currently unused
    my $rc = shift;	# anon hash passed
    my $config_dir = $ENV{XDG_CONFIG_HOME} // $ENV{HOME} . '/.config';
    my $rc_file = shift // $config_dir . '/invoicerc';

    my $keyfile = Glib::KeyFile->new;
    $keyfile->load_from_file ($rc_file, 'keep-comments');

    if ($keyfile->has_group ('invoice')) {
	if ($keyfile->has_key ('invoice', 'payperiod_file')) {
	    $rc->{payperiod_file} = $keyfile->get_string ('invoice', 'payperiod_file');
	}
	else {
	    $rc->{payperiod_file} = '~/Dropbox/docs/training/business/payperiod';
	}

	if ($keyfile->has_key ('invoice', 'archive_dir')) {
	    $rc->{archive_dir} = $keyfile->get_string ('invoice', 'archive_dir');
	}
	else {
	    $rc->{archive_dir} = '~/Dropbox/docs/training/business/payperiod_archive/';
	}

	if ($keyfile->has_key ('invoice', 'invoices_dir')) {
	    $rc->{invoices_dir} = $keyfile->get_string ('invoice', 'invoices_dir');
	}
	else {
	    $rc->{invoices_dir} = '~/Dropbox/docs/training/business/invoices';
	}

	if ($keyfile->has_key ('invoice', 'count_file')) {
	    $rc->{count_file} = $keyfile->get_string ('invoice', 'count_file');
	}
	else {
	    $rc->{count_file} = '~/Dropbox/docs/training/business/invoices';
	}

	if ($keyfile->has_key ('invoice', 'template_file')) {
	    $rc->{template_file} = $keyfile->get_string ('invoice', 'template_file');
	}
	else {
	    $rc->{template_file} = '~/Dropbox/docs/training/business/invoices/_template.odt';
	}
    }
    else {}

    my $g = $opts->{invoicee};
    if ($keyfile->has_group ($g)) {
	if ($keyfile->has_key ($g, 'template_file')) {
	    $rc->{template_file} = $keyfile->get_string ($g, 'template_file');
	}

	$opts->{payperiod_file} .= '-' . $g;
    }

    $g .= '-rates';
    if ($keyfile->has_group ($g)) {
	my @r = $keyfile->get_keys ($g);
	foreach (@r) {
	    $opts->{$_} = $keyfile->get_string ($g, $_);
	}
    }

    # debugging:
    if ($debug) {
    	foreach (sort keys %{$opts}) {
	    print "$_ = ", $opts->{$_}, "\n";
    	}
    }

    # no need to return because $rc is an anon hash
}


__END__

=head1 NAME

invoice.pl

=head1 VERSION

0.1

=head1 SYNOPSIS

invoice.pl [OPTIONS] [FILE]

=head1 DESCRIPTION

This program translates a flat-file list of client sessions into an invoice
suitable for printing.

=head1 OPTIONS

=over 8

=item B<-c>

Provide an alternative config file.

=item B<-v>

Opens the resulting invoice file in the specified viewer.

=item B<-p>

Sends the invoice file to the printer.

=item B<-r>

Outputs the invoice as plain text to STDOUT, as it would appear in the
final invoice.

=back

=head1 AUTHOR

Written by Ian D. Brunton

=head1 REPORTING BUGS

Report bugs to iandbrunton at gmail.com

=head1 COPYRIGHT

Copyright 2017 Ian D. Brunton.

invoice.pl is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later viersion.

invoice.pl is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for details.

You should have received a copy of the GNU General Public License along with
invoice.pl.  If not, see <http://www.gnu.org/licenses/>.

=cut
