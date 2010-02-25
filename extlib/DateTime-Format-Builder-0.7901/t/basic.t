#!/usr/bin/perl -wT

use strict;
use Test::More tests => 5;

BEGIN {
    use_ok 'DateTime::Format::Builder';
}

my $class = 'DateTime::Format::Builder';

# Does new() work properly?
{
    eval { $class->new('fnar') };
    ok(( $@ and $@ =~ /takes no param/), "Too many parameters exception" );

    my $obj = eval { $class->new() };
    ok( !$@, "Created object" );
    isa_ok( $obj, $class );

    eval { $obj->parse_datetime( "whenever" ) };
    ok(( $@ and $@ =~ /No parser/), "No parser exception" );

}
