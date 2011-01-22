package IDB;

=head1 NAME

IDB - contains miscellaneous subs

=cut

sub double_digit {
    my $int = shift;
    return $int < 10 ? '0' . $int : $int;
}

sub year {
    my $int = shift;
    return $int + 1900;
}

1;
