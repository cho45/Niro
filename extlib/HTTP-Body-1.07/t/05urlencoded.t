#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 31;

use Cwd;
use Digest::MD5 qw(md5_hex);
use HTTP::Body;
use File::Spec::Functions;
use IO::File;
use PAML;

my $path = catdir( getcwd(), 't', 'data', 'urlencoded' );

for ( my $i = 1; $i <= 6; $i++ ) {

    my $test    = sprintf( "%.3d", $i );
    my $headers = PAML::LoadFile( catfile( $path, "$test-headers.pml" ) );
    my $results = PAML::LoadFile( catfile( $path, "$test-results.pml" ) );
    my $content = IO::File->new( catfile( $path, "$test-content.dat" ) );
    my $body    = HTTP::Body->new( $headers->{'Content-Type'}, $headers->{'Content-Length'} );

    binmode $content, ':raw';

    while ( $content->read( my $buffer, 1024 ) ) {
        $body->add($buffer);
    }

    is_deeply( $body->body, $results->{body}, "$test UrlEncoded body" );
    is_deeply( $body->param, $results->{param}, "$test UrlEncoded param" );
    is_deeply( $body->upload, $results->{upload}, "$test UrlEncoded upload" );
    cmp_ok( $body->state, 'eq', 'done', "$test UrlEncoded state" );
    cmp_ok( $body->length, '==', $body->content_length, "$test UrlEncoded length" );
    
    # Check trailing header on the chunked request
    if ( $i == 3 ) {
        my $content = IO::File->new( catfile( $path, "002-content.dat" ) );
        binmode $content;
        $content->read( my $buf, 4096 );
        is( $body->trailing_headers->header('Content-MD5'), md5_hex($buf), "$test trailing header ok" );
    }
}
