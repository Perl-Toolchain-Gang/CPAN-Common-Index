use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index::MetaDB;
# ABSTRACT: Search index via CPAN MetaDB
# VERSION

use parent 'CPAN::Common::Index';

use Carp;
use CPAN::Meta::YAML;
use HTTP::Tiny;

sub attributes {
    return {
        uri => "http://cpanmetadb.plackperl.org/v1.0/"
    };
}

sub validate_attributes {
    my ($self) = @_;

    # ensure URI ends in '/'
    my $uri = $self->uri;
    $uri =~ s{/?$}{/};
    $self->uri($uri);

    return 1;
}

sub search_packages {
    my ( $self, $args ) = @_;
    Carp::croak("Argument to search_packages must be hash reference")
      unless ref $args eq 'HASH';

    # only support direct package query
    return unless keys %$args == 1 && exists $args->{package} && ref $args->{package} eq '';

    my $mod = $args->{package};
    my $res = HTTP::Tiny->new->get($self->uri . "package/$mod");
    return unless $res->{success};

    if ( my $yaml = CPAN::Meta::YAML->read_string($res->{content}) ) {
        my $meta = $yaml->[0];
        if ($meta && $meta->{distfile}) {
            my $file = $meta->{distfile};
            $file =~ s{^./../}{}; # strip leading
            return {
                package => $mod,
                version => $meta->{version},
                uri     => "cpan:///distfile/$file",
            };
        }
    }

    return;
}

sub index_age { return time }; # pretend always current

sub search_authors { return }; # not supported

__PACKAGE__->_build_accessors;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use CPAN::Common::Index::MetaDB;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
