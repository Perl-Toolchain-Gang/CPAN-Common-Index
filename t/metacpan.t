use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::FailWarnings;
use Test::Deep '!blessed';
use Test::Fatal;
use HTTP::Tiny;

my $test_url = "http://api.metacpan.org";

plan skip_all => "Can't reach MetaCPAN"
  unless HTTP::Tiny->new->get($test_url)->{success};

require_ok("CPAN::Common::Index::MetaCPAN");

subtest "constructor tests" => sub {
    # no arguments, all defaults
    new_ok(
        'CPAN::Common::Index::MetaCPAN' => [],
        "new with no args"
    );

    # uri specified
    new_ok(
        'CPAN::Common::Index::MetaCPAN' => [ { uri => "http://api.example.org/v2" } ],
        "new with cache"
    );

};

subtest 'find package' => sub {
    my $index = new_ok("CPAN::Common::Index::MetaCPAN");

    my $got = $index->search_packages( { package => 'Moose' } );
    ok( $got,                "found package" );
    ok( $got->{version} > 2, "has a version" );
    like(
        $got->{uri},
        qr{^cpan:///distfile/\w+/Moose-\d+\.\d+\.tar.gz$},
        "uri format looks OK"
    );
};

subtest 'find package with a specific version' => sub {
    my $index = new_ok("CPAN::Common::Index::MetaCPAN");

    my $got = $index->search_packages( { package => 'Plack', version => "1.0000" } );
    ok( $got,                      "found package" );
    is( $got->{version}, '1.0000', "has a right version" );
    is(
        $got->{uri},
        "cpan:///distfile/MIYAGAWA/Plack-1.0000.tar.gz",
        "uri is OK"
    );
};

subtest 'find package with a version range' => sub {
    my $index = new_ok("CPAN::Common::Index::MetaCPAN");

    my $got = $index->search_packages( { package => 'Plack', version_range  => "< 1" } );
    ok( $got,                "found package" );
    ok( $got->{version} < 1, "has a right version" );
    like(
        $got->{uri},
        qr{^cpan:///distfile/MIYAGAWA/Plack-0\.9.*\.tar\.gz$},
        "uri format looks OK"
    );
};

subtest 'find package with a dev release' => sub {
    my $index = new_ok("CPAN::Common::Index::MetaCPAN" => [ { include_dev => 1 } ]);

    my $got = $index->search_packages( { package => 'CPAN::Test::Dummy::Perl5::Developer' } );
    ok( $got, "found package" );
    like(
        $got->{uri},
        qr{^cpan:///distfile/\w+/CPAN-Test-Dummy-Perl5-Developer-[0-9_\.]*\.tar\.gz$},
        "uri format looks OK"
    );
};

subtest 'find a package in BackPAN' => sub {
    my $index = new_ok("CPAN::Common::Index::MetaCPAN");

    my $got = $index->search_packages( { package => 'Try::Tiny', version => '0.18' } );
    ok( $got, "found package" );
    is(
        $got->{uri},
        "cpan:///distfile/DOY/Try-Tiny-0.18.tar.gz",
        "uri is OK",
    );
    is(
        $got->{download_uri},
        "http://backpan.perl.org/authors/id/D/DO/DOY/Try-Tiny-0.18.tar.gz",
        "download_uri is there with backpan",
    );
};

subtest 'find a version staying package' => sub {
    my $index = new_ok("CPAN::Common::Index::MetaCPAN");

    my $got = $index->search_packages( { package => 'CPAN::Test::Dummy::Perl5::VersionBump::Stay' } );
    ok( $got, "found package" );
    is(
        $got->{uri},
        "cpan:///distfile/MIYAGAWA/CPAN-Test-Dummy-Perl5-VersionBump-0.02.tar.gz",
        "uri is OK",
    );
};

subtest 'find a version decreasing package' => sub {
    my $index = new_ok("CPAN::Common::Index::MetaCPAN");

    my $got = $index->search_packages( { package => 'CPAN::Test::Dummy::Perl5::VersionBump::Decrease' } );
    ok( $got, "found package" );
    is(
        $got->{uri},
        "cpan:///distfile/MIYAGAWA/CPAN-Test-Dummy-Perl5-VersionBump-0.01.tar.gz",
        "uri is OK",
    );
};

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
