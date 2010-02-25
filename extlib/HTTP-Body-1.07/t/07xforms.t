#!perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More tests => 12;

use Cwd;
use HTTP::Body;
use File::Spec::Functions;
use IO::File;
use PAML;

my $path = catdir( getcwd(), 't', 'data', 'xforms' );

for ( my $i = 1; $i <= 2; $i++ ) {

    my $test    = sprintf( "%.3d", $i );
    my $headers = PAML::LoadFile( catfile( $path, "$test-headers.pml" ) );
    my $results = PAML::LoadFile( catfile( $path, "$test-results.pml" ) );
    my $content = IO::File->new( catfile( $path, "$test-content.dat" ) );
    my $body    = HTTP::Body->new( $headers->{'Content-Type'}, $headers->{'Content-Length'} );

    binmode $content, ':raw';

    while ( $content->read( my $buffer, 1024 ) ) {
        $body->add($buffer);
    }
    
    # Save tempnames for later deletion
    my @temps;
    
    for my $field ( keys %{ $body->upload } ) {

        my $value = $body->upload->{$field};

        for ( ( ref($value) eq 'ARRAY' ) ? @{$value} : $value ) {
            push @temps, delete $_->{tempname};
        }
    }

    is_deeply( $body->body, $results->{body}, "$test XForms body" );
    is_deeply( $body->param, $results->{param}, "$test XForms param" );
    is_deeply( $body->upload, $results->{upload}, "$test XForms upload" );
    if ( $body->isa('HTTP::Body::XFormsMultipart') ) {
        cmp_ok( $body->start, 'eq', $results->{start}, "$test XForms start" );
    }
    else {
        ok( 1, "$test XForms start" );
    }
    cmp_ok( $body->state, 'eq', 'done', "$test XForms state" );
    cmp_ok( $body->length, '==', $headers->{'Content-Length'}, "$test XForms length" );
    
    # Clean up temp files created
    unlink map { $_ } grep { defined $_ && -e $_ } @temps;
}
