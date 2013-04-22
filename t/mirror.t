use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::FailWarnings;
use Test::Deep '!blessed';
use Test::Fatal;

use Cwd qw/getcwd/;
use File::Temp;
use File::Spec::Functions qw/catfile/;

use lib 't/lib';
use CommonTests;

my $cwd         = getcwd;
my $test_mirror = "file:///$cwd/t/CPAN";
my $cache       = File::Temp->newdir;
my $mailrc      = "01mailrc.txt";
my $packages    = "02packages.details.txt";

sub new_mirror_index {
    my $index = new_ok(
        'CPAN::Common::Index::Mirror' => [ { cache => $cache, mirror => $test_mirror } ],
        "new with cache and mirror"
    );
}

require_ok("CPAN::Common::Index::Mirror");

subtest "constructor tests" => sub {
    # no arguments, all defaults
    new_ok(
        'CPAN::Common::Index::Mirror' => [],
        "new with no args"
    );

    # cache specified
    new_ok(
        'CPAN::Common::Index::Mirror' => [ { cache => $cache } ],
        "new with cache"
    );

    # mirror specified
    new_ok(
        'CPAN::Common::Index::Mirror' => [ { mirror => $test_mirror } ],
        "new with mirror"
    );

    # both specified
    new_mirror_index;

    # unknown argument
    eval { CPAN::Common::Index::Mirror->new( { mirror => $test_mirror, foo => 'bar' } ) };
    like(
        $@ => qr/Unknown arguments to new\(\): foo/,
        "Unknown argument dies with error"
    );

    # bad argument
    eval { CPAN::Common::Index::Mirror->new( mirror => $test_mirror, foo => 'bar' ) };
    like(
        $@ => qr/Argument to new\(\) must be a hash reference/,
        "Non hashref argument dies with error"
    );
};

subtest 'refresh and unpack index files' => sub {
    my $index = new_mirror_index;

    for my $file ( $mailrc, "$mailrc.gz", $packages, "$packages.gz" ) {
        ok( ! -e catfile($cache, $file), "$file not there" );
    }
    ok( $index->refresh_index, "refreshed index" );
    for my $file ( $mailrc, "$mailrc.gz", $packages, "$packages.gz" ) {
        ok( -e catfile($cache, $file), "$file is there" );
    }
};

# XXX test that files in cache aren't overwritten?

subtest 'check index age' => sub {
    my $index = new_mirror_index;
    my $package = $index->cached_package;
    ok( -f $package, "got the package file" );
    my $expected_age = (stat($package))[9];
    is( $index->index_age, $expected_age, "index_age() is correct" );
};

subtest 'find package' => sub {
    my $index = new_mirror_index;
    test_find_package( $index );
};

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
