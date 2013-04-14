use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index::Mirror;
# ABSTRACT: Search index via CPAN mirror flatfiles
# VERSION

use parent 'CPAN::Common::Index';

use File::Spec;
use File::Temp 0.19; # newdir

sub attributes {
    return {
        cache  => sub { File::Temp->newdir },
        mirror => "http://www.cpan.org/",
    };
}

my @INDICES = qw(
  t/CPAN/authors/01mailrc.txt
  t/CPAN/modules/02packages.details.txt
);

sub validate_attributes {
    my ($self) = @_;
    my $cache = $self->cache;
    if ( ! -d $cache ) {
        Carp::croak("Cache directory '$cache' does not exist");
    }
    # XXX validate mirror URL?
    return 1;
}

# XXX on demand, we want to get the indices from the mirror to
# the cache, probably using File::Fetch so we can handle any
# sort of URL.

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
