use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index;
# ABSTRACT: Common library for searching CPAN modules, authors and distributions
# VERSION

use Carp ();

#--------------------------------------------------------------------------#
# class construction
#--------------------------------------------------------------------------#

sub _build_accessors {
    my $class = shift;
    for my $k ( keys %{ $class->attributes } ) {
        no strict 'refs';
        *{ $class . "::$k" } = sub {
            return @_ > 1 ? $_[0]->{$k} = $_[1] : $_[0]->{$k};
        };
    }
    return 1; # so it can be last line of modules
}

#--------------------------------------------------------------------------#
# object construction
#--------------------------------------------------------------------------#

sub new {
    my ( $class, $args ) = @_;
    $args = {} unless defined $args;
    if ( ref $args ne 'HASH' ) {
        Carp::croak("Argument to new() must be a hash reference");
    }

    # for attributes, grab them from args and create accessors if
    # not already created
    my %attributes;
    my $defaults = $class->attributes;
    for my $k ( keys %$defaults ) {
        if ( exists $args->{$k} ) {
            $attributes{$k} = delete $args->{$k};
        }
        else {
            my $d = $defaults->{$k};
            $attributes{$k} = ref $d eq 'CODE' ? $d->() : $d;
        }
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

#--------------------------------------------------------------------------#
# stub methods
#--------------------------------------------------------------------------#

# default reload reques does nothing; may not apply to some subclasses
sub refresh_index { 1 }

# default validation does nothing
sub validate_attributes { 1 }

#--------------------------------------------------------------------------#
# abstract method: must be implmented in subclasses
#--------------------------------------------------------------------------#

# search_modules: data from 02packages.details.txt
# arguments: key/value pairs;  keys can be 'package',
# 'distribution', 'version' or 'author'.
# value can be exact or regex; should return URI's
# for location

# search_authors: returns data from 01mailrc.txt
# arguments: key/value pairs; keys can be 'author'
# value can be exact or regex


# index_age: how old the index is in seconds

my @abstract_methods = qw(
  search_packages
  search_authors
  index_age
);

for my $m (@abstract_methods) {
    no strict 'refs';
    *{ __PACKAGE__ . "::$m" } = sub {
        my ($self) = @_;
        Carp::croak( "$m() not implemented by " . ( ref $self or $self ) );
    };
}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

    use CPAN::Common::Index::Mux::Ordered;
    use Data::Dumper;

    my $index = CPAN::Common::Index::Mux::Ordered->assemble(
        MetaDB => {},
        Mirror => { mirror => "http://cpan.cpantesters.org" },
    );

    my $result = $index->search_packages( { package => "Moose" } );

    print Dumper($result);

    # {
    #   package => 'MOOSE',
    #   version => '2.0802',
    #   uri     => "cpan:///distfile/ETHER/Moose-2.0802.tar.gz"
    # }

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
