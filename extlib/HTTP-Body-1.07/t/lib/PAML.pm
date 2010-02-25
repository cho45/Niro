package PAML;
use strict;
use warnings;

# "PAML Ain't Markup Language"!!!

use Carp         qw[croak];
use Data::Dumper qw[];
use IO::File     qw[];

BEGIN {
    our @EXPORT_OK = qw(
        DumpFile
        LoadFile
    );

    require Exporter;
    *import = \&Exporter::import;
}

sub DumpFile ($$) {
    my ($path, $struct) = @_;

    my $data = do {
        local $Data::Dumper::Indent = 1;
        local $Data::Dumper::Purity = 1;
        local $Data::Dumper::Terse  = 1;
        local $Data::Dumper::Useqq  = 1;
        Data::Dumper->Dump([$struct], ['PAML']);
    };

    my $io = IO::File->new($path, '>')
      || croak(qq[Couldn't open path '$path' in write mode: $!]);

    $io->binmode
      || croak(qq[Couldn't binmode filehandle: $!]);

    $io->print($data)
      || croak(qq[Couldn't write filehandle: $!]);

    $io->close
      || croak(qq[Couldn't close filehandle: $!]);

    1;
}

sub LoadFile ($) {
    my ($path) = @_;

    my $data = do {

        my $io = IO::File->new($path, '<')
          || corak(qq[Couldn't open path '$path' in read mode: $!]);

        $io->binmode
          || croak(qq[Couldn't binmode filehandle: $!]);

        my $exp = -s $path;
        my $buf = do { local $/; <$io> };
        my $got = length $buf;

        $io->close
          || croak(qq[Couldn't close filehandle: $!]);

        ($exp == $got)
          || croak(qq[I/O read mismatch, expexted: $exp got: $got]);

        $buf;
    };

    if (substr($data, 0, 1) eq '{') {
        substr($data, 0, 0, '+');
    }

    my $struct = eval($data);

    (!$@)
      || croak(qq[LoadFile couldn't eval data: $@]);

    $struct;
}

1;

