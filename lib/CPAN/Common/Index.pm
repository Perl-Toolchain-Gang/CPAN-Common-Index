use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index;
# ABSTRACT: No abstract given for CPAN::Common::Index
# VERSION

use Carp ();

sub new {
    my ( $class, $args ) = @_;
    if ( ref $args ne 'HASH' ) {
        Carp::croak("Argument to new() must be a hash reference");
    }

    # for attributes, grab them from args and create accessors if
    # not already created
    my %attributes;
    for my $k ( $class->attributes ) {
        $attributes{$k} = delete $args->{$k} if exists $args->{$k};
    }
    if ( keys %$args ) {
        Carp::croak( "Unknown arguments to new(): " . join( " ", keys %$args ) );
    }
    my $self = bless \%attributes, $class;
    eval { $self->validate_attributes };
    if ( my $err = $@ ) {
        Carp::croak("Object failed validation: $@");
    }
    return $self;
}

sub _build_accessors {
    my $class = shift;
    for my $k ( $class->attributes ) {
        no strict 'refs';
        *{ $class . "::$k" } = sub {
            return @_ > 1 ? $_[0]->{$k} = $_[1] : $_[0]->{k};
        };
    }
    return 1; # so it can be last line of modules
}

# default validation does nothing
sub validate_attributes { 1 }

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use CPAN::Common::Index;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
