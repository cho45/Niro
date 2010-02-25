#!/usr/bin/perl -w

use strict;
use Test::More tests => 10;

use_ok 'Text::MicroMason';

ok my $mason_class = Text::MicroMason->class();
ok my $m = $mason_class->new();

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
}

######################################################################

{
    my $scr_bold = '<b><% $ARGS{label} %></b>';
    is $m->execute( text => $scr_bold, label=>'Foo'), '<b>Foo</b>';
    is $m->compile( text => $scr_bold)->(label=>'Foo'), '<b>Foo</b>';
}

######################################################################

{
    my $scr_mobj = 'You\'ve been compiled by <% ref $m %>.';
    my $res_mobj = 'You\'ve been compiled by Text::MicroMason';

    like $m->execute( text => $scr_mobj), qr/^\Q$res_mobj\E/;
}

######################################################################
