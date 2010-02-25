#!/usr/bin/perl -w

use strict;
use Test::More tests => 9;

use_ok 'Text::MicroMason', qw( compile execute );

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

    is execute($scr_hello), $res_hello;
    is compile($scr_hello)->(), $res_hello;

    ok my $scriptlet = compile($scr_hello);
    is $scriptlet->(), $res_hello;
    is $scriptlet->(), $res_hello;
    is $scriptlet->(), $res_hello;
}

######################################################################

{
    my $scr_bold = '<b><% $ARGS{label} %></b>';
    is execute($scr_bold, label=>'Foo'), '<b>Foo</b>';
    is compile($scr_bold)->(label=>'Foo'), '<b>Foo</b>';
}

