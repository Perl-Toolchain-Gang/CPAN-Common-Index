requires "CPAN::DistnameInfo" => "0";
requires "CPAN::Meta::YAML" => "0";
requires "Carp" => "0";
requires "Class::Tiny" => "0";
requires "File::Basename" => "0";
requires "File::Fetch" => "0";
requires "File::Temp" => "0.19";
requires "HTTP::Tiny" => "0";
requires "IO::Uncompress::Gunzip" => "0";
requires "Module::Load" => "0";
requires "Path::Tiny" => "0";
requires "Search::Dict" => "1.07";
requires "Tie::Handle::SkipHeader" => "0";
requires "URI" => "0";
requires "parent" => "0";
requires "perl" => "5.008001";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "Cwd" => "0";
  requires "Exporter" => "0";
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec::Functions" => "0";
  requires "List::Util" => "0";
  requires "Test::Deep" => "0";
  requires "Test::FailWarnings" => "0";
  requires "Test::Fatal" => "0";
  requires "Test::More" => "0.96";
  requires "lib" => "0";
  requires "version" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "0";
  recommends "CPAN::Meta::Requirements" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.17";
};

on 'develop' => sub {
  requires "Dist::Zilla" => "5.014";
  requires "Dist::Zilla::Plugin::Encoding" => "0";
  requires "Dist::Zilla::PluginBundle::DAGOLDEN" => "0.060";
  requires "File::Spec" => "0";
  requires "File::Temp" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Meta" => "0";
  requires "Test::More" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};
