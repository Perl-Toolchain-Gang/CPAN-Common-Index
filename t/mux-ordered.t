use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
use Test::FailWarnings;
use Test::Deep '!blessed';
use Test::Fatal;

use lib 't/lib';
use CommonTests;

use CPAN::Common::Index::Mirror;
use CPAN::Common::Index::Mux::Ordered;

my $mirror = new_ok( 'CPAN::Common::Index::Mirror', [ { root => 't/CPAN' } ] );

my $index =
  new_ok( 'CPAN::Common::Index::Mux::Ordered', [ { resolvers => [$mirror] } ] );

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
