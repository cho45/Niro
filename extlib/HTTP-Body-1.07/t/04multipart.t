#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 140;
use Test::Deep;

use Cwd;
use HTTP::Body;
use File::Spec::Functions;
use IO::File;
use PAML;
use File::Temp qw/ tempdir /;

my $path = catdir( getcwd(), 't', 'data', 'multipart' );

for ( my $i = 1; $i <= 13; $i++ ) {

    my $test    = sprintf( "%.3d", $i );
    my $headers = PAML::LoadFile( catfile( $path, "$test-headers.pml" ) );
    my $results = PAML::LoadFile( catfile( $path, "$test-results.pml" ) );
    my $content = IO::File->new( catfile( $path, "$test-content.dat" ) );
    my $body    = HTTP::Body->new( $headers->{'Content-Type'}, $headers->{'Content-Length'} );
    my $tempdir = tempdir( 'XXXXXXX', CLEANUP => 1, DIR => File::Spec->tmpdir() );
    $body->tmpdir($tempdir);

    my $regex_tempdir = quotemeta($tempdir);

    binmode $content, ':raw';

    while ( $content->read( my $buffer, 1024 ) ) {
        $body->add($buffer);
    }
    
    # Tests >= 10 use auto-cleanup
    if ( $i >= 10 ) {
        $body->cleanup(1);
    }
    
    # Save tempnames for later deletion
    my @temps;
    
    for my $field ( keys %{ $body->upload } ) {

        my $value = $body->upload->{$field};

        for ( ( ref($value) eq 'ARRAY' ) ? @{$value} : $value ) {
            like($_->{tempname}, qr{$regex_tempdir}, "has tmpdir $tempdir");
            push @temps, $_->{tempname};
        }
        
        # Tell Test::Deep to ignore tempname values
        if ( ref $value eq 'ARRAY' ) {
            for ( @{ $results->{upload}->{$field} } ) {
                $_->{tempname} = ignore();
            }
        }
        else {
            $results->{upload}->{$field}->{tempname} = ignore();
        }
    }

    cmp_deeply( $body->body, $results->{body}, "$test MultiPart body" );
    cmp_deeply( $body->param, $results->{param}, "$test MultiPart param" );
    cmp_deeply( $body->upload, $results->{upload}, "$test MultiPart upload" )
        if $results->{upload};
    cmp_ok( $body->state, 'eq', 'done', "$test MultiPart state" );
    cmp_ok( $body->length, '==', $body->content_length, "$test MultiPart length" );
    
    if ( $i < 10 ) {
        # Clean up temp files created
        unlink map { $_ } grep { -e $_ } @temps;
    }
    
    undef $body;
    
    # Ensure temp files were deleted
    for my $temp ( @temps ) {
        ok( !-e $temp, "Temp file $temp was deleted" );
    }
} 
