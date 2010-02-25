use strict;
use warnings;

use Test::More;

eval 'use Encode';
plan skip_all => 'These tests require Encode.pm'
    unless eval 'use Encode; 1';

plan skip_all => 'These tests require Perl 5.8.8+'
    unless $] >= 5.008008;

plan tests => 2;

use Devel::StackTrace;


# This should be invalid UTF8
my $raw_bad = do { use bytes; chr( 0xED ) . chr( 0xA1 ) . chr( 0xBA ) };

my $decoded = Encode::decode( 'utf8' => $raw_bad );
my $trace = foo( $decoded );

my $string = eval { $trace->as_string() };

my $e = $@;
is( $e, '',
    'as_string() does not throw an exception' );
like( $string, qr/\Q(bad utf-8)/,
      'stringified output notes bad utf-8' );


sub foo
{
    Devel::StackTrace->new();
}
