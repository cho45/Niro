#!/usr/bin/perl -w

use strict;
use Test::More tests => 13;

use_ok 'Text::MicroMason';

######################################################################

{
    ok my $m = Text::MicroMason->new( -AllowGlobals );
    ok $m->allow_globals( '$name' );
    is $m->execute( text=>'Hello <% $name || "" %>!' ), 'Hello !';
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -AllowGlobals );
    ok $m->allow_globals( '$name' );
    ok $m->set_globals( '$name' => 'Bob' );
    is $m->execute( text=>'Hello <% $name %>!' ), 'Hello Bob!';
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -AllowGlobals );
    ok $m->allow_globals( '$count' );
    ok my $sub = $m->compile( text=>'Item <% ++ $count %>.' );
    is $sub->(), 'Item 1.';
    is $sub->(), 'Item 2.';
}

######################################################################
