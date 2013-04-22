use strict;
use warnings;
package CommonTests;

use Exporter;
use Test::More;

our @ISA = qw/Exporter/;
our @EXPORT = qw(
    test_find_package
);

sub test_find_package {
    my $index = shift;
    
    my @cases = (
        {
            package => 'File::Marker',
            version => '0.13',
            uri => 'cpan:///distfile/DAGOLDEN/File-Marker-0.13.tar.gz',
        },
        {
            package => 'Dist::Zilla',
            version => '4.300034',
            uri => 'cpan:///distfile/RJBS/Dist-Zilla-4.300034.tar.gz',
        },
        {
            package => 'Moo::Role',
            version => 'undef',
            uri => 'cpan:///distfile/MSTROUT/Moo-1.001000.tar.gz',
        },
        {
            package => 'attributes',
            version => '0.2',
            uri => 'cpan:///distfile/FLORA/perl-5.17.4.tar.bz2',
        },
    );

    for my $c (@cases) {
        my $got = $index->search_packages( { name => $c->{package} } );
        is_deeply( $got, $c, "find $c->{package}" );
    }

}

1;

