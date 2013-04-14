use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::FailWarnings;
use Test::Deep '!blessed';
use Test::Fatal;
use Cwd qw/getcwd/;
use File::Temp;

use lib 't/lib';
use CommonTests;

my $cwd         = getcwd;
my $test_mirror = "file:///$cwd/t/CPAN";
my $cache       = File::Temp->newdir;

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
    new_ok(
        'CPAN::Common::Index::Mirror' => [ { cache => $cache, mirror => $test_mirror } ],
        "new with cache and mirror"
    );

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

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
