use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index::Mux::Ordered;
# ABSTRACT: Consult indices in order and return the first result
# VERSION

use parent 'CPAN::Common::Index';

use Module::Load ();

sub attributes {
    return {
        resolvers => sub { [] },
    };
}

sub assemble {
    my ($class, @backends) = @_;

    my @resolvers;

    while ( @backends ) {
        my ( $subclass, $config ) = splice @backends, 0, 2;
        my $full_class = "${class}::${subclass}";
        eval { Module::Load::load( $full_class ) }
            or Carp::croak($@);
        my $object = $full_class->new( $config );
        push @resolvers, $object;
    }

    return $class->new( { resolvers => \@resolvers } );
}

sub validate_attributes {
    my ($self) = @_;
    my $resolvers = $self->resolvers;
    if ( ref $resolvers ne 'ARRAY' ) {
        Carp::croak("The 'resolvers' argument must be an array reference");
    }
    for my $r ( @{$self->resolvers} ) {
        if ( ! eval { $r->isa("CPAN::Common::Index") } ) {
            Carp::croak("Resolver '$r' is not a CPAN::Common::Index object");
        }
    }
    return 1;
}

__PACKAGE__->_build_accessors;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use CPAN::Common::Index::Mux::Ordered;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
