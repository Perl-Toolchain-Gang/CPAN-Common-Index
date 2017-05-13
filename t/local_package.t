use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::FailWarnings;
use Test::Deep '!blessed';
use Test::Fatal;

use Cwd qw/getcwd/;
use File::Spec;
use File::Temp ();

use lib 't/lib';
use CommonTests;

my $HAS_IO_UNCOMPRESS_GUNZIP = eval { require IO::Uncompress::Gunzip };

my $cwd          = getcwd;
my $cache        = File::Temp::tempdir(CLEANUP => 1, TMPDIR => 1);
my $localgz      = File::Spec->catfile(qw/t CUSTOM mypackages.gz/);
my $local        = File::Spec->catfile(qw/t CUSTOM uncompressed/);
my $packages     = "mypackages";
my $uncompressed = "uncompressed";

sub new_local_index {
    my $index = new_ok(
        'CPAN::Common::Index::LocalPackage' => [ { cache => $cache, source => $localgz } ],
        "new with cache and local gz"
    );
}

sub new_uncompressed_local_index {
    my $index = new_ok(
        'CPAN::Common::Index::LocalPackage' => [ { cache => $cache, source => $local } ],
        "new with cache and local uncompressed"
    );
}

require_ok("CPAN::Common::Index::LocalPackage");

subtest "constructor tests" => sub {
    # no arguments, all defaults
    like(
        exception { CPAN::Common::Index::LocalPackage->new() },
        qr/'source' parameter must be provided/,
        "new with no args dies because source is required"
    );

    # missing file
    like(
        exception {
            CPAN::Common::Index::LocalPackage->new( { source => 'LDJFLKDJLJDLKD' } );
        },
        qr/index file .* does not exist/,
        "new with invalid source dies"
    );

    # source specified
    new_ok(
        'CPAN::Common::Index::LocalPackage' => [ { source => $localgz } ],
        "new with source"
    );

    # both specified
    new_local_index;

    # uncompressed variant
    new_uncompressed_local_index;
};

subtest 'refresh and unpack index files' => sub {
    plan skip_all => "IO::Uncompress::Gunzip is not available"
      unless $HAS_IO_UNCOMPRESS_GUNZIP;
    my $index = new_local_index;

    ok( !-e File::Spec->catfile( $cache, $packages ), "$packages not in cache" );

    ok( $index->refresh_index, "refreshed index" );

    ok( -e File::Spec->catfile( $cache, $packages ), "$packages in cache" );
};

subtest 'refresh and unpack uncompressed index files' => sub {
    my $index = new_uncompressed_local_index;

    ok( !-e File::Spec->catfile( $cache, $uncompressed ), "$uncompressed not in cache" );

    ok( $index->refresh_index, "refreshed index" );

    ok( -e File::Spec->catfile( $cache, $uncompressed ), "$uncompressed in cache" );
};

# XXX test that files in cache aren't overwritten?

subtest 'check index age' => sub {
    my $index =
      $HAS_IO_UNCOMPRESS_GUNZIP ? new_local_index : new_uncompressed_local_index;
    my $package = $index->cached_package;
    ok( -f $package, "got the package file" );
    my $expected_age = ( stat($package) )[9];
    is( $index->index_age, $expected_age, "index_age() is correct" );
};

subtest 'find package' => sub {
    my $index =
      $HAS_IO_UNCOMPRESS_GUNZIP ? new_local_index : new_uncompressed_local_index;
    test_find_package($index);
};

subtest 'search package' => sub {
    my $index =
      $HAS_IO_UNCOMPRESS_GUNZIP ? new_local_index : new_uncompressed_local_index;
    test_search_package($index);
};

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
