use 5.008001;
use strict;
use warnings;

package CPAN::Common::Index::Mirror;
# ABSTRACT: Search index via CPAN mirror flatfiles
# VERSION

use parent 'CPAN::Common::Index';

use CPAN::DistnameInfo;
use File::Basename ();
use File::Fetch;
use File::Temp 0.19; # newdir
use IO::Uncompress::Gunzip ();
use Search::Dict;
use Tie::Handle::SkipHeader;
use URI;

sub attributes {
    return {
        cache  => sub { File::Temp->newdir },
        mirror => "http://www.cpan.org/",
    };
}

sub validate_attributes {
    my ($self) = @_;

    # cache directory needs to exist
    my $cache = $self->cache;
    if ( !-d $cache ) {
        Carp::croak("Cache directory '$cache' does not exist");
    }

    # ensure URL ends in '/'
    my $mirror = $self->mirror;
    $mirror =~ s{/?$}{/};
    $self->mirror($mirror);

    return 1;
}

my %INDICES = (
    mailrc   => 'authors/01mailrc.txt.gz',
    packages => 'modules/02packages.details.txt.gz',
);

sub cached_package {
    my ($self) = @_;
    my $package = File::Spec->catfile( $self->cache,
        File::Basename::basename( $INDICES{packages} ) );
    $package =~ s/\.gz$//;
    $self->refresh_index unless -r $package;
    return $package;
}

sub cached_mailrc {
    my ($self) = @_;
    my $mailrc =
      File::Spec->catfile( $self->cache, File::Basename::basename( $INDICES{mailrc} ) );
    $mailrc =~ s/\.gz$//;
    $self->refresh_index unless -r $mailrc;
    return $mailrc;
}

sub refresh_index {
    my ($self) = @_;
    for my $file ( values %INDICES ) {
        my $remote = URI->new_abs( $file, $self->mirror );
        my $ff = File::Fetch->new( uri => $remote );
        my $where = $ff->fetch( to => $self->cache )
          or Carp::croak( $ff->error );
        ( my $uncompressed = $where ) =~ s/\.gz$//;
        IO::Uncompress::Gunzip::gunzip( $where, $uncompressed )
          or Carp::croak "gunzip failed: $IO::Uncompress::Gunzip::GunzipError\n";
    }
    return 1;
}

# epoch secs
sub index_age {
    my ($self) = @_;
    my $package = $self->cached_package;
    return ( -r $package ? ( stat($package) )[9] : 0 ); # mtime if readable
}

sub search_packages {
    my ( $self, $args ) = @_;
    Carp::croak("Argument to search_modules must be hash reference")
      unless ref $args eq 'HASH';

    my $index_path = $self->cached_package;
    die "Can't read $index_path" unless -r $index_path;
    tie *PD, 'Tie::Handle::SkipHeader', "<", $index_path;

    # Convert scalars or regexps to subs
    my $rules;
    if ( $args->{name} ) {
        if ( $args->{name} eq 'CODE' ) {
            $rules->{name} = $args->{name};
        }
        else {
            my $re = ref $args->{name} eq 'Regexp' ? $args->{name} : qr/\A\Q$args->{name}\E\z/;
            $rules->{name} = sub { $_[0] =~ $re };
        }
    }

    if ( $args->{version} ) {
        if ( ref $args->{version} eq 'CODE' ) {
            $rules->{version} = $args->{version};
        }
        else {
            my $v = version->parse( $args->{version} );
            $rules->{version} = sub {
                eval { version->parse( $_[0] ) == $v };
            };
        }
    }

    my @found;
    if ( $args->{name} and ref $args->{name} eq '' ) {
        # binary search 02packages on name
        my $pos = look * PD, $args->{name}, { xform => \&_xform, fold => 1 };
        return if $pos == -1;
        # XXX eventually, loop lines until name doesn't match so we can
        # search an index with unique package+version, not just package
        my $line = <PD>;
        push @found, _match_line( $line, $rules );
    }
    else {
        # iterate all lines looking for match
        LINE: while ( my $line = <PD> ) {
            push @found, _match_line( $line, $rules );
        }
    }
    return wantarray ? @found : $found[0];
}

sub search_authors { ... }

sub _xform {
    my @fields = split " ", $_[0], 2;
    return $fields[0];
}

sub _match_line {
    my ( $line, $rules ) = @_;
    my ( $mod, $version, $dist, $comment ) = split " ", $line, 4;
    if ( $rules->{name} ) {
        return unless $rules->{name}->($mod);
    }
    if ( $rules->{version} ) {
        return unless $rules->{version}->($version);
    }
    $dist =~ s{\A./../}{};
    return {
        package => $mod,
        version => $version,
        uri     => "cpan:///distfile/$dist",
    };
}

__PACKAGE__->_build_accessors;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use CPAN::Common::Index::Mirror;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
