use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index::Util;
# ABSTRACT: Utility functions for CPAN::Common::Index

our $VERSION = '0.008';

sub gunzip {
    my ($src, $dest) = @_;
    if ( eval { require IO::Uncompress::Gunzip } ) {
        no warnings 'once';
        IO::Uncompress::Gunzip::gunzip($src, $dest)
          or die "gunzip failed: $IO::Uncompress::Gunzip::GunzipError\n";
        return 1;
    }
    else {
        require File::Which;
        require IPC::Run3;
        my $gzip = File::Which::which("gzip")
          or die "can't find IO::Uncompress::Gunzip nor gzip command\n";
        IPC::Run3::run3( [$gzip, '--decompress', '--stdout', $src], \undef, $dest, \my $err );
        return 1 if $? == 0;
        chomp $err;
        die $err ? $err : "gunzip failed: \$? = $?", "\n";
    }
}

1;
