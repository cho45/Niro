#!/usr/bin/perl -w

use strict;
use Test::More tests => 9;

use_ok 'Text::MicroMason';

######################################################################

{
    ok my $m = Text::MicroMason->new( -PassVariables );
    is $m->execute( text=>'Hello <% $name || "" %>!' ), 'Hello !';
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -PassVariables );
    is $m->execute( text=>'Hello <% $name %>!', 'name' => 'Bob' ), 'Hello Bob!';
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -PassVariables, package => 'foo' );
    $foo::name = $foo::name = 'Bob';
    is $m->execute( text=>'Hello <% $name %>!' ), 'Hello Bob!';
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -PassVariables, package => 'main' );
    local $::name; $::name = 'Bob';
    is $m->execute( text=>'Hello <% $name %>!' ), 'Hello Bob!';
}

######################################################################
