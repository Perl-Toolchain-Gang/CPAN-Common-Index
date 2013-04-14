use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index::Mirror;
# ABSTRACT: Search index via CPAN mirror flatfiles
# VERSION

use parent 'CPAN::Common::Index';

use File::Spec;

sub attributes { qw/root/ }

my @INDICES = qw(
  t/CPAN/authors/01mailrc.txt
  t/CPAN/modules/02packages.details.txt
);

sub validate {
    my ($self) = @_;
    my $root = $self->root;
    if ( !defined $root ) {
        Carp::croak("Required attribute 'root' missing");
    }
    for my $path (@INDICES) {
        if ( ! -r File::Spec->catfile($root, $path) ) {
            Carp::croak("Can't find readable index file '$path'");
        }
    }
    return 1;
}

__PACKAGE__->_build_accessors;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use CPAN::Common::Index::Mirror;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
