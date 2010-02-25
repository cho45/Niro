#!/usr/bin/perl -w

use strict;
use Test::More tests => 8;

use_ok 'Text::MicroMason';
ok my $m = Text::MicroMason->new();

######################################################################

{
    my $scr_hello = <<'ENDSCRIPT';
% my $noun = 'World';
Hello <% $noun %>!
How are ya?
ENDSCRIPT

    my $res_hello = <<'ENDSCRIPT';
Hello World!
How are ya?
ENDSCRIPT

    is $m->execute( text => $scr_hello), $res_hello;
    is $m->compile( text => $scr_hello)->(), $res_hello;

    ok my $scriptlet = $m->compile( text => $scr_hello);
    is $scriptlet->(), $res_hello;
    is $scriptlet->(), $res_hello;
    is $scriptlet->(), $res_hello;
}

######################################################################
