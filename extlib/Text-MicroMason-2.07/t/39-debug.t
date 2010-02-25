#!/usr/bin/perl -w

use strict;
use Test::More tests => 4;

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason->new( -Debug, debug => { default => 0 } );

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

    ok my $scriptlet = $m->compile( text => $scr_hello);
    is $scriptlet->(), $res_hello;
}

######################################################################
