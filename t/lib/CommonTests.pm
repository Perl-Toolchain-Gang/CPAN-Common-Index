use strict;
use warnings;

package CommonTests;

use Exporter;
use Test::More;

our @ISA    = qw/Exporter/;
our @EXPORT = qw(
  test_find_package
  test_search_package
  test_find_author
  test_search_author
);

sub test_find_package {
    my $index = shift;

    my @cases = (
        {
            package => 'File::Marker',
            version => '0.13',
            uri     => 'cpan:///distfile/DAGOLDEN/File-Marker-0.13.tar.gz',
        },
        {
            package => 'Dist::Zilla',
            version => '4.300034',
            uri     => 'cpan:///distfile/RJBS/Dist-Zilla-4.300034.tar.gz',
        },
        {
            package => 'Moo::Role',
            version => 'undef',
            uri     => 'cpan:///distfile/MSTROUT/Moo-1.001000.tar.gz',
        },
        {
            package => 'attributes',
            version => '0.2',
            uri     => 'cpan:///distfile/FLORA/perl-5.17.4.tar.bz2',
        },
    );

    for my $c (@cases) {
        my $got = $index->search_packages( { package => $c->{package} } );
        is_deeply( $got, $c, "find $c->{package}" );
    }
}

sub test_search_package {
    my $index = shift;

    my @cases = (
        {
            label  => 'query on package',
            query  => { package => qr/e::Marker$/, },
            result => [
                {
                    package => 'File::Marker',
                    version => '0.13',
                    uri     => 'cpan:///distfile/DAGOLDEN/File-Marker-0.13.tar.gz',
                }
            ],
        },
        {
            label => 'query on package and version',
            query => {
                package => qr/Marker$/,
                version => 0.13,
            },
            result => [
                {
                    package => 'File::Marker',
                    version => '0.13',
                    uri     => 'cpan:///distfile/DAGOLDEN/File-Marker-0.13.tar.gz',
                }
            ],
        },
        {
            label  => 'query on dist',
            query  => { dist => qr/1\.4404\.tar\.gz$/, },
            result => [
                {
                    'package' => 'Parse::CPAN::Meta',
                    'uri'     => 'cpan:///distfile/DAGOLDEN/Parse-CPAN-Meta-1.4404.tar.gz',
                    'version' => '1.4404'
                }
            ],
        },
    );

    for my $c (@cases) {
        my @got = $index->search_packages( $c->{query} );
        is_deeply( \@got, $c->{result}, $c->{label} ) or diag explain \@got;
    }
}

sub test_find_author {
    my $index = shift;

    my @cases = (
        {
            id       => 'DAGOLDEN',
            fullname => 'David Golde',
            email    => 'dagolden@cpan.org',
        },
    );

    for my $c (@cases) {
        my $got = $index->search_authors( { id => $c->{id} } );
        is_deeply( $got, $c, "find $c->{id}" );
    }
}

sub test_search_author {
    my $index = shift;

    my @cases = (
        {
            label  => 'query on id',
            query  => { id => qr/DAGOLD/, },
            result => [
                {
                    id       => 'DAGOLDEN',
                    fullname => 'David Golde',
                    email    => 'dagolden@cpan.org',
                },
            ],
        },
    );

    for my $c (@cases) {
        my @got = $index->search_authors( $c->{query} );
        is_deeply( \@got, $c->{result}, $c->{label} ) or diag explain \@got;
    }
}

1;

