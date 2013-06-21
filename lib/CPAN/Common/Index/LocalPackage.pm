use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index::LocalPackage;
# ABSTRACT: Search index via custom local CPAN package flatfile
# VERSION

use parent 'CPAN::Common::Index::Mirror';

use Carp;
use IO::Uncompress::Gunzip ();
use Path::Tiny;

sub attributes {
    my $attrs = $_[0]->SUPER::attributes;
    delete $attrs->{mirror};
    $attrs->{source} = undef;
    return $attrs;
}

sub validate_attributes {
    my ($self) = @_;

    my $file = $self->source;
    if ( !defined $file ) {
        Carp::croak("'source' parameter must be provided");
    }
    elsif ( !-f $file ) {
        Carp::croak("index file '$file' does not exist");
    }

    return 1;
}

sub cached_package {
    my ($self) = @_;
    my $package = path( $self->cache, path( $self->source )->basename );
    $package =~ s/\.gz$//;
    $self->refresh_index unless -r $package;
    return $package;
}

sub refresh_index {
    my ($self) = @_;
    my $source = path( $self->source );
    if ( $source =~ /\.gz$/ ) {
        ( my $uncompressed = $source->basename ) =~ s/\.gz$//;
        $uncompressed = path( $self->cache, $uncompressed );
        if ( !-f $uncompressed or $source->stat->mtime > $uncompressed->stat->mtime ) {
            IO::Uncompress::Gunzip::gunzip( map { "$_" } $source, $uncompressed )
              or Carp::croak "gunzip failed: $IO::Uncompress::Gunzip::GunzipError\n";
        }
    }
    else {
        my $dest = path( $self->cache, $source->basename );
        $source->copy($dest)
          if ! -e $dest || $source->stat->mtime > $dest->stat->mtime;
    }
    return 1;
}

sub search_authors { return }; # this package handles packages only

__PACKAGE__->_build_accessors;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use CPAN::Common::Index::LocalPackage;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
