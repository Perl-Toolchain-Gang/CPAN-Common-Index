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

=method new

    $index = $class->new( \%args );

The constructor arguments must be given a hash reference.  The specific
keys allowed are defined by each backend.

=cut

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
# Document abstract methods
#--------------------------------------------------------------------------#

=method search_packages (ABSTRACT)

    $result = $index->search_packages( { package => "Moose" });
    @result = $index->search_packages( \%advanced_query );

Searches the index for a package such as listed in the CPAN
F<02packages.details.txt> file.  The query must be provided as a hash
reference.  Valid keys are

=for :list
* package -- a string, regular expression or code reference
* version -- a version number or code reference
* dist -- a string, regular expression or code reference

If the query term is a string or version number, the query will be for an exact
match.  If a code reference, the code will be called with the value of the
field for each potential match.  It should return true if it matches.

Not all backends will implement support for all fields or all types of queries.
If it does not implement either, it should "decline" the query with an empty
return.

The return should be context aware, returning either a
single result or a list of results.

The result must be formed as follows:

    {
      package => 'MOOSE',
      version => '2.0802',
      uri     => "cpan:///distfile/ETHER/Moose-2.0802.tar.gz"
    }

The C<uri> field should a valid URI.  It may be a L<URI::cpan> or any other
URI.  (It is up to a client to do something useful with any given URI scheme.)

=method search_authors (ABSTRACT)

    $result = $index->search_authors( { id => "DAGOLDEN" });
    @result = $index->search_authors( \%advanced_query );

Searches the index for author data such as from the CPAN F<01mailrc.txt> file.
The query must be provided as a hash reference.  Valid keys are

=for :list
* id -- a string, regular expression or code reference
* fullname -- a string, regular expression or code reference
* email -- a string, regular expression or code reference

If the query term is a string, the query will be for an exact match.  If a code
reference, the code will be called with the value of the field for each
potential match.  It should return true if it matches.

Not all backends will implement support for all fields or all types of queries.
If it does not implement either, it should "decline" the query with an empty
return.

The return should be context aware, returning either a single result or a list
of results.

The result must be formed as follows:

    {
        id       => 'DAGOLDEN',
        fullname => 'David Golden',
        email    => 'dagolden@cpan.org',
    }

The C<email> field may not reflect an actual email address.  The 01mailrc file
on CPAN often shows "CENSORED" when email addresses are concealed.

#--------------------------------------------------------------------------#
# stub methods
#--------------------------------------------------------------------------#

=method index_age

    $epoch = $index->index_age;

Returns the modification time of the index in epoch seconds.  This may not make sense
for some backends.  By default it returns the current time.

=cut

sub index_age { time }

=method refresh_index

    $index->refresh_index;

This ensures the index source is up to date.  For example, a remote
mirror file would be re-downloaded.  By default, it does nothing.

=cut

sub refresh_index { 1 }

=method attributes

Return attributes and default values as a hash reference.  By default
returns an empty hash reference.

=cut

sub attributes { {} }

=method validate_attributes

    $self->validate_attributes;

This is called by the constructor to validate any arguments.  Subclasses
should override the default one to perform validation.  It should not be
called by application code.  By default, it does nothing.

=cut

sub validate_attributes { 1 }


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

This module provides a common library for working with a variety of CPAN index
services.  It is intentionally minimalist, trying to use as few non-core
modules as possible.

The C<CPAN::Common::Index> module is an abstract base class that defines a
common API.  Individual backends deliver the API for a particular index.

As shown in the SYNOPSIS, one interesting application is multiplexing -- using
different index backends, querying each in turn, and returning the first
result.

=cut

# vim: ts=4 sts=4 sw=4 et:
