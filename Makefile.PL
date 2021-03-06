use strict;
use warnings;

use 5.008001;

use ExtUtils::MakeMaker 6.17;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Common library for searching CPAN modules, authors and distributions",
  "AUTHOR" => "David Golden <dagolden\@cpan.org>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.17"
  },
  "DISTNAME" => "CPAN-Common-Index",
  "LICENSE" => "apache",
  "MIN_PERL_VERSION" => "5.008001",
  "NAME" => "CPAN::Common::Index",
  "PREREQ_PM" => {
    "CPAN::DistnameInfo" => 0,
    "CPAN::Meta::YAML" => 0,
    "Carp" => 0,
    "Class::Tiny" => 0,
    "File::Basename" => 0,
    "File::Copy" => 0,
    "File::Fetch" => 0,
    "File::Spec" => 0,
    "File::Temp" => "0.19",
    "File::stat" => 0,
    "HTTP::Tiny" => 0,
    "Module::Load" => 0,
    "Search::Dict" => "1.07",
    "Tie::Handle::SkipHeader" => 0,
    "URI" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Cwd" => 0,
    "Exporter" => 0,
    "ExtUtils::MakeMaker" => 0,
    "File::Spec" => 0,
    "File::Spec::Functions" => 0,
    "Test::Deep" => 0,
    "Test::FailWarnings" => 0,
    "Test::Fatal" => 0,
    "Test::More" => "0.96",
    "lib" => 0
  },
  "VERSION" => "0.011",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "CPAN::DistnameInfo" => 0,
  "CPAN::Meta::YAML" => 0,
  "Carp" => 0,
  "Class::Tiny" => 0,
  "Cwd" => 0,
  "Exporter" => 0,
  "ExtUtils::MakeMaker" => 0,
  "File::Basename" => 0,
  "File::Copy" => 0,
  "File::Fetch" => 0,
  "File::Spec" => 0,
  "File::Spec::Functions" => 0,
  "File::Temp" => "0.19",
  "File::stat" => 0,
  "HTTP::Tiny" => 0,
  "Module::Load" => 0,
  "Search::Dict" => "1.07",
  "Test::Deep" => 0,
  "Test::FailWarnings" => 0,
  "Test::Fatal" => 0,
  "Test::More" => "0.96",
  "Tie::Handle::SkipHeader" => 0,
  "URI" => 0,
  "lib" => 0,
  "parent" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
