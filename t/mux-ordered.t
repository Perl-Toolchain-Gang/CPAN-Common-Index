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
require_ok("CPAN::Common::Index::Mux::Ordered");

my $mirror_index = CPAN::Common::Index::Mirror->new(
    { cache => $cache, mirror => $test_mirror }
);

subtest "constructor tests" => sub {
    # no arguments, all defaults
    new_ok(
        'CPAN::Common::Index::Mux::Ordered' => [],
        "new with no args"
    );

    # single resolver specified
    new_ok(
        'CPAN::Common::Index::Mux::Ordered' => [ { resolvers => [ $mirror_index ] } ],
        "new with single mirror resolver"
    );

    # bad resolver argument
    eval { CPAN::Common::Index::Mux::Ordered->new( { resolvers => "Foo" } ) };
    like(
        $@ => qr/The 'resolvers' argument must be an array reference/,
        "Bad resolver dies with error"
    );

    # unknown argument
    eval { CPAN::Common::Index::Mux::Ordered->new( { foo => 'bar' } ) };
    like(
        $@ => qr/Unknown arguments to new\(\): foo/,
        "Unknown argument dies with error"
    );

    # bad argument
    eval { CPAN::Common::Index::Mux::Ordered->new( foo => 'bar' ) };
    like(
        $@ => qr/Argument to new\(\) must be a hash reference/,
        "Non hashref argument dies with error"
    );
};


done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
