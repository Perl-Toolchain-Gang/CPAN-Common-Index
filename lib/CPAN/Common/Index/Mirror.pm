use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index::Mirror;
# ABSTRACT: Search index via CPAN mirror flatfiles
# VERSION

use parent 'CPAN::Common::Index';

use File::Temp 0.19; # newdir
use File::Fetch;
use IO::Uncompress::Gunzip ();
use URI;

sub attributes {
    return {
        cache  => sub { File::Temp->newdir },
        mirror => "http://www.cpan.org/",
    };
}

sub validate_attributes {
    my ($self) = @_;

    # cache directory needs to exist
    my $cache = $self->cache;
    if ( !-d $cache ) {
        Carp::croak("Cache directory '$cache' does not exist");
    }

    # ensure URL ends in '/'
    my $mirror = $self->mirror;
    $mirror =~ s{/?$}{/};
    $self->mirror($mirror);

    return 1;
}

# XXX on demand, we want to get the indices from the mirror to
# the cache, probably using File::Fetch so we can handle any
# sort of URL.
my @INDICES = qw(
  authors/01mailrc.txt.gz
  modules/02packages.details.txt.gz
);

sub refresh_index {
    my ($self) = @_;
    for my $file (@INDICES) {
        my $remote = URI->new_abs( $file, $self->mirror );
        my $ff = File::Fetch->new( uri => $remote );
        my $where = $ff->fetch( to => $self->cache );
        ( my $uncompressed = $where ) =~ s/\.gz$//;
        IO::Uncompress::Gunzip::gunzip( $where, $uncompressed );
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
