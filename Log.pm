package Log;
use strict;
use Date::Calc 'Add_Delta_Days';
use Time::Local 'timelocal_nocheck';
use Glib;
use IDB;

=head1 NAME

Log

=head1 SYNOPSIS

Class to implement log/journal processing

=head1 Methods

=head2 new

Constructor. Requires no arguments.

=cut

sub new {
    my $class = shift;
    my $self = {};
    bless( $self, "Log" );
    $self->_init();
    return $self;
}

sub _init {
    my $self = shift;
	
    # set default options (all of these can be set in .logrc):
    $self->{log_dir} = $ENV{HOME} . '/docs/log/';
    $self->{snippet_dir} = $ENV{HOME} . '/docs/log/.snippets/';
    $self->{state_file} = $self->{log_dir} . '.state';
    $self->{auto_round} = 0;
    $self->{auto_echo} = 0;
    $self->{mark_rounded} = 0;
    $self->{rounded_time_char} = '~';
    $self->{comment_char} = ';;';
    $self->{predictor_char} = '[';
    $self->{end_of_line} = "\n";
    $self->{extension} = '';
    $self->{indent_char} = "\t";
    $self->{line_length} = 70;
    $self->{tag}->{end} = '[m'; # don't change this unless you know what you're doing
    # $self->{tag}->{comment} = '\033[32m';
    # $self->{tag}->{t} = '\033[32m';
    # $self->{tag}->{h} = '\033[43m\033[30m';
    # $self->{tag}->{d} = '\033[41m\033[30m';
    # $self->{tag}->{c} = '\033[36m';
    # $self->{tag}->{o} = '\033[1;35m';
    # $self->{tag}->{x} = '\033[1;35m';
    # $self->{tag}->{n} = '\033[36m';
	
    return $self;
}

=head2 getopts

Parses command-line -options.

=cut
sub getopts {
    my $self = shift;
    my $allowed = shift;
    my $string = shift;
    my $tags;
	
    #    print "Log.pm: \$\$string = '$$string'\n";
    if ( $$string !~ /^-/ ) {	# no options passed
	return $self;
    }
    #    elsif ( $$string =~ /^(-[$allowed]+\s?)(?!-)/o ) {
    elsif ( $$string =~ /^((-[a-zA-Z0-9]+ ?)+)(?!-)/ ) {
	$tags = $1;
	$$string =~ s/$tags//;
    } else {
	$self->set_opt( 'h' );
	return $self;
    }

    $allowed .= join ('', keys %{$self->{extensions}});

    # date differential:
    if ($tags =~ /-(\d+)/) {
	$self->{date_diff} = $1;
	$self->{has_diff} = 1;
    }

    $tags =~ s/[^a-zA-Z]//g;
    # print "Log.pm: \$tags = $tags\n";
    my $t;
    for ( my $i = 0; $i < length( $tags ); $i++ ) {
	$t = substr( $tags, $i, 1 );
	if ( $t =~ /[$allowed]/ ) {
	    $self->set_opt( $t );
	} else {
	    $self->error( "Unknown command-line option `$t'." );
	}
    }
    $self->process_options;
    return $self;
}

sub process_options {
    my $self = shift;
	
    if ( $self->opt( 'a' ) ) {
	$self->{end_of_line} = '';
    }
    if ( $self->opt( 'c' ) ) {
	$self->set_opt( 't' );
	$self->indent_char( $self->{comment_char} . $self->{indent_char} ) ;
    }
    if ( $self->opt( 'i' ) ) {
	$self->set_opt( 't' );
    }
    if ( $self->opt( 'n' ) ) {
	$self->set_opt( 't' );
    }
    # if ( $self->opt( 'R' ) ) { $self->unset_opt( 'r' ); }
    # if ( $self->opt( 'r' ) ) { $self->unset_opt( 'R' ); }

    foreach (keys %{$self->{extensions}}) {
	if ($self->opt ($_)) {
	    $self->{extension} = '.' . $self->{extensions}->{$_};
	}
    }
	
    # This is an ad hoc hack to make .journal files behave in a specific way.
    # It would be preferable to be able to write this as a hook in the config file
    if ( $self->opt( 'J' ) ) {
	$self->{end_of_line} = "\n\n";
	$self->{indent_char} = '';
	$self->set_opt( 't' );
	$self->set_opt( 'r' );
    }
    
    # if ( $self->opt( 'j' ) && $self->opt( 't' ) ) {
    # 	$self->error( 'Cannot pass both -j and -t.' );
    # }
	
    return $self;
}

=head2 parse_rc_file [FILE]

Reads in a configuration file (F<~/.logrc> by default, but other
values may be passed) and parses its values into a hash structure.

=cut

sub parse_rc {
    my $self = shift;
    $self->{rc_file} = shift // $ENV{'XDG_CONFIG_HOME'} . '/logrc';
    if ( -s $self->{rc_file}) {
	my $keyfile = Glib::KeyFile->new;
	$keyfile->load_from_file ($self->{rc_file}, 'keep-comments');

	if ($keyfile->has_group ('log')) {
	    if ($keyfile->has_key ('log', 'log_dir')) {
		$self->{log_dir} = $keyfile->get_string ('log', 'log_dir');
		$self->{log_dir} =~ s/(\$HOME|\~)/$ENV{'HOME'}/;
	    }

	    if ($keyfile->has_key ('log', 'snippet_dir')) {
		$self->{snippet_dir} = $keyfile->get_string ('log', 'snippet_dir');
		$self->{snippet_dir} =~ s/(\$HOME|\~)/$ENV{'HOME'}/;
	    }

	    if ($keyfile->has_key ('log', 'editor')) {
		$self->{editor} = $keyfile->get_string ('log', 'editor');
	    }

	    if ($keyfile->has_key ('log', 'alternate_editor')) {
		$self->{alternate_editor} = $keyfile->get_string ('log', 'alternate_editor');
	    }

	    if ($keyfile->has_key ('log', 'line_length')) {
		$self->{line_length} = $keyfile->get_integer ('log', 'line_length');
	    }

	    if ($keyfile->has_key ('log', 'auto_round')) {
		$self->{auto_round} = $keyfile->get_boolean ('log', 'auto_round');
	    }

	    if ($keyfile->has_key ('log', 'mark_rounded')) {
		$self->{mark_rounded} = $keyfile->get_boolean ('log', 'mark_rounded');
	    }

	    if ($keyfile->has_key ('log', 'rounded_time_char')) {
		$self->{rounded_time_char} = $keyfile->get_string ('log', 'rounded_time_char');
	    }

	    if ($keyfile->has_key ('log', 'auto_echo')) {
		$self->{auto_echo} = $keyfile->get_boolean ('log', 'auto_echo');
	    }

	    if ($keyfile->has_key ('log', 'comment_char')) {
		$self->{comment_char} = $keyfile->get_string ('log', 'comment_char');
	    }

	    if ($keyfile->has_key ('log', 'predictor_char')) {
		$self->{predictor_char} = $keyfile->get_string ('log', 'predictor_char');
	    }

	    if ($keyfile->has_key ('log', 'end_of_line')) {
		$self->{end_of_line} = $keyfile->get_string ('log', 'end_of_line');
	    }

	    if ($keyfile->has_key ('log', 'indent_char')) {
		$self->{indent_char} = $keyfile->get_string ('log', 'indent_char');
	    }

	    if ($keyfile->has_key ('log', 'underline_start')) {
		$self->{underline_start} = $keyfile->get_string ('log', 'underline_start');
	    }

	    if ($keyfile->has_key ('log', 'underline_end')) {
		$self->{underline_end} = $keyfile->get_string ('log', 'underline_end');
	    }
	}

	if ($keyfile->has_group ('tags')) {
	    my @ttags = $keyfile->get_keys ('tags');

	    foreach (@ttags) {
		$self->{tag}->{$_} = $keyfile->get_string ('tags', $_);
	    }
	}

	if ($keyfile->has_group ('extensions')) {
	    my @textensions = $keyfile->get_keys ('extensions');

	    foreach (@textensions) {
		$self->{extensions}->{$_} = $keyfile->get_string ('extensions', $_);
	    }
	}
    }

    return $self;
}

=head2 parse_state [FILE]

Reads data previously stored by the script in order to influence
the current instance. By default the file is F<.state> within the
directory specified by log_dir, unless another filename is passed.

=cut
sub parse_state {
    my $self = shift;
    $self->{state_file} // $self->{log_dir} . '.state';
    if ( -s $self->{state_file} ) {
	open( FILE, $self->{state_file} ) || die();
	while ( <FILE> ) {
	    push( @{$self->{state}}, $_ );
	}
	close( FILE );
    }
    return $self;
}

sub state {
    my $self = shift;
    return shift @{$self->{state}};
}

=head2 parse_datetime [STRING]

Reads input data and extracts date, time, and comments for separate
processing from remaining text.

=cut
sub parse_datetime {
    my $self = shift;
    my $string = shift;
	
    #    print "Log.pm->parse_datetime: $$string\n";
	
    # date:
    if ( $$string =~ m|^((\d{4}/)?(\d{2}/)?\d{2})\b|o ) {
	$self->{date} = $1;
	$$string =~ s/$1 *//o;
	$self->{has_date} = 1;
    }
    # date differential:	### DEPRECATED 2012-10-25 ###
    if ( $$string =~ m|\b(n\d+?)\b| ) {
	$self->{date_diff} = $1;
	$$string =~ s/$1 *//o;
	$self->{date_diff} =~ s/\D//g;
	$self->{has_diff} = 1;
    }
    # time:
    if ( $$string =~ s/^(\[?\d{4}[~?]?):? */$1:\t/o ) {
	$self->{time} = $1;
	$self->{has_time} = 1;
	$self->set_opt( 't' );
    } elsif ( $$string =~ s/^(\w{1,6}:) +/$1\t/o ) {
    	$self->set_opt( 't' );
    }
	
    #    print "Log.pm->parse_datetime: date=" . $self->{date},"\n";
    #    $self->{input} = $$string;
    #    print ">>Log.pm->parse_datetime: " . $self->{date} . "\n";
    $self->get_date;
    #    print ">>Log.pm->parse_datetime: " . $self->{date} . "\n";
    $self->set_time;
	
    return $self;
}

=head2 get_date

Takes date parsed by parse_datetime and calculates the date to use, as
well as setting the file_path and date_string.

=cut
sub get_date {
    my $self = shift;
	
    my $key = join( '/', &IDB::year( (localtime(time))[5] ),
		    &IDB::double_digit( (localtime(time))[4] + 1 ),
		    &IDB::double_digit( (localtime(time))[3] ) );
	
    if ( $self->{has_date} ) {
	if ( $self->{date} ne $key ) {
	    if ( $self->{date} =~ m|^(\d{2}/\d{2})$| ) { # MM/DD provided, use current year
		$self->{date} = substr( $key, 0, 5 ) .= $1;
	    } elsif ( $self->{date} =~ m|^(\d{2})$| ) { # DD provided, use current year and month
		$self->{date} = substr( $key, 0, 8 ) .= $1;
	    }
	    #else { $self->error( 'Incorrectly formatted date: ' . $self->{date} ); }
	} else {
	    $self->{date} = $key;
	}
    } else {
	$self->{date} = $key;
    }
	
    if ( $self->{has_diff} ) {
	my @newdate = Add_Delta_Days( split( /\//, $self->{date} ), 0 - $self->{date_diff} );
	$newdate[2] = &IDB::double_digit( $newdate[2] );
	$newdate[1] = &IDB::double_digit( $newdate[1] );
	$newdate[0] = &IDB::double_digit( $newdate[0] );;
		
	$self->{date} = join( '/', @newdate );
    }
	
    # set file_paths:
    $self->{file_path} = $self->{log_dir} . $self->{date};
    $self->{base_path} = $self->{log_dir} . $self->{date};

    if ($self->{extension} ne '') {
	$self->{file_path} .= $self->{extension};
    }	

    # if ( $self->opt( 't' ) ) { $self->{file_path} .= $self->{training_extension}; }
    # elsif ( $self->opt( 'j' ) ) { $self->{file_path} .= $self->{journal_extension}; }
	
    if ( ! -e $self->{file_path} ) {
	$self->{is_new} = 1;
    }
	
    $self->{year} = substr( $self->{date}, 0, 4 );
    $self->{month} = substr( $self->{date}, 5, 2 );
    $self->{day} = substr( $self->{date}, 8, 2 );
	
    $self->{dir_path} = $self->{log_dir} . join( '/', $self->{year},
						 $self->{month} );
	
    my $months = [ 'January', 'February', 'March', 'April', 'May', 'June',
		   'July', 'August', 'September', 'October', 'November', 'December' ];
    my $weekdays = [ 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
		     'Friday', 'Saturday' ];
    my $weekday = (localtime(timelocal_nocheck(0, 0, 0, $self->{day},
					       $self->{month} - 1, $self->{year})))[6];
	
    $self->{date_string} = $weekdays->[$weekday] . ', ' . $self->{day} . ' '
      . $months->[$self->{month} - 1] . ', ' . $self->{year};
	
    return $self;
}



=head2 set_time

According to set options, sets the time for the current entry.

=cut
sub set_time {
    my $self = shift;
	
    if ( $self->{has_time} && ! $self->opt( 'n' ) ) {
	return $self;
    }				# so as not to overwrite
	
    my $hour = (localtime)[2];
    my $min = (localtime)[1];
	
    if ( $self->opt('r') || $self->{auto_round} ) {
	my $mod = $min % 5;
	if ($mod == 1) {
	    $min -= 1;
	} elsif ($mod == 2) {
	    $min -= 2;
	} elsif ($mod == 3) {
	    $min += 2;
	} elsif ($mod == 4) {
	    $min += 1;
	} else {
	    $self->unset_opt ('r');
	}

	if ( $min == 60 ) {
	    $min = 0;
	    $hour++;
	}
    }
	
    # $hour = &IDB::double_digit( $hour );
    # $min = &IDB::double_digit( $min );
    # $self->{time} = $hour . $min;
    $self->{time} = &IDB::double_digit( $hour ) . &IDB::double_digit( $min );
	
    $self->{has_time} = 1;
    #    print "Log.pm->set_time: $hour, $min, " . $self->{time} . "\n";
	
    if (($self->opt ('r') || $self->{auto_round}) && $self->{mark_rounded}) {
	$self->{time} .= $self->{rounded_time_char};
    }

    return $self;
}

=head2 opt OPTION

Returns the value of OPTION.

=cut
sub opt {
    my $self = shift;
    my $which = shift;
    return $self->{opt}->{$which};
}

=head2 set_opt OPTION

Sets OPTION to 1.

=cut
sub set_opt {
    my $self = shift;
    my $which = shift;
    $self->{opt}->{$which} = 1;
	
    # if certain options are set, others should also be set
    return $self;
}

=head2 unset_opt OPTION

Sets OPTION to 0.

=cut
sub unset_opt {
    my $self = shift;
    my $which = shift;
    delete $self->{opt}->{$which};
    return $self;
}

# various methods to return object properties:
sub log_dir		{ my $self = shift; return $self->{log_dir}; }
sub snippet_dir { my $self = shift; return $self->{snippet_dir}; }
sub state_file	{ my $self = shift; return $self->{state_file}; }
sub comment_char { my $self = shift; return $self->{comment_char}; }
sub predictor_char { my $self = shift; return $self->{predictor_char}; }
sub end_of_line	{ my $self = shift; return $self->{end_of_line}; }
sub line_length	{ my $self = shift; return $self->{line_length}; }
sub date		{ my $self = shift; return $self->{date}; }
sub date_string	{ my $self = shift; return $self->{date_string}; }
sub year		{ my $self = shift; return $self->{year}; }
sub month		{ my $self = shift; return $self->{month}; }
sub time		{ my $self = shift; return $self->{time}; }
sub has_time	{ my $self = shift; return $self->{has_time}; }
sub file_path	{ my $self = shift; return $self->{file_path}; }
sub is_new		{ my $self = shift; return $self->{is_new}; }

sub indent_char {
    my $self = shift;
    if ( @_ ) {
	$self->{indent_char} = shift; return $self;
    } else {
	return $self->{indent_char};
    }
}

sub replace_tags {
    my $self = shift;
    my $string = shift;
	
    unless ( $self->{tags_off}) {
	# date:
	$$string =~ s/^((\w+), \d{2} (\w+), \d{4})$/$self->date_tag($1)/egi;
	# inline tag:
	$$string =~ s/\$([a-z]){1}(.+?)\$(?=\W)/$self->tag($1,$2)/eg;
	# tag from start of line:
	$$string =~ s/^(.+)\$([A-Z])/$self->tag($2,$1)/e;
	# comment:
	$$string =~ s/(;;.+)$/$self->comment_tag($1)/e;
	# tags:
	$$string =~ s/^(\#.+)$/$self->comment_tag($1)/e;
	# underline:
	$$string =~ s|/([^,;]+)/|$self->underline($1)|eg;
    }
    return $self;
}

sub tag {
    my $self = shift;
    my $tag = lc( shift );
    my $text = shift;
    if ( ! exists $self->{tag}->{$tag} || $self->opt ('m') ) {
	return $text;
    }
    return $self->{tag}->{$tag} . $text . $self->end_tag;
}

sub end_tag {
    my $self = shift;
    return $self->{tag}->{end};
}

sub date_tag {
    my $self = shift;
    #    return `echo -e "$self->{tag}->{date}"` . ">> " . shift() . $self->end_tag;
    return $self->{tag}->{date} . shift() . $self->end_tag;
}

sub comment_tag {
    my $self = shift;
    #    return `echo -e "$self->{tag}->{comment}"` . shift() . $self->end_tag;
    return $self->{tag}->{comment} . shift() . $self->end_tag;
}

sub underline {
    my $self = shift;
    return $self->{underline_start} . shift () . $self->{underline_end};
}

sub expand_snippets {
    my $self = shift;
    my $snippet = shift;
    
    my $snippet_file = $self->snippet_dir . $snippet;
    if ( -e $snippet_file ) {
	open( SNIPPET, "<$snippet_file" ) || die( "Cannot open file $snippet_file: $!\n" );
	my @file_contents = <SNIPPET>;
	close( SNIPPET );
	my $str = join( "", @file_contents );
	$str =~ s/\n$//so; # chop \n off the end
	
	my $ic = $self->indent_char;
	if ($str =~ s/#BR#/\n$ic/g) {
	    $self->set_opt('w');
	}
	
	return $str;
    }
    else { return $snippet; }
}

sub AUTOLOAD {
    my $self = shift;
    our $AUTOLOAD;
    my $subname = $AUTOLOAD;
    return $self->{$subname};
}

sub error {
    my $self = shift;
    my $err = shift;
    $err =~ s/\n$//o;
    print "Log.pm/Error: $err\n\n";
    exit 0;
}

1;

=head1 AUTHOR

Written by Ian D. Brunton

=head1 REPORTING BUGS

Report Log bugs to ibrunton@accesswave.ca

=head1 COPYRIGHT

Copyright 2011, 2012 Ian Brunton.

This file is part of Log.

Log is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Log is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Log.  If not, see <http://www.gnu.org/licenses/>.

=cut  
