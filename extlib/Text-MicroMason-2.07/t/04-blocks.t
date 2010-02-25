#!/usr/bin/perl -w

use strict;
use Test::More tests => 12;

use_ok 'Text::MicroMason';
ok my $m = Text::MicroMason->new();

######################################################################

SIMPLE_INIT_BLOCK: {
    my $scr_hello = <<'ENDSCRIPT';
I'm sorry <% $name %>, I'm afraid I can't do that right now.
<%init>
  my $name = 'Dave';
</%init>
ENDSCRIPT

    my $res_hello = <<'ENDSCRIPT';
I'm sorry Dave, I'm afraid I can't do that right now.
ENDSCRIPT

    is $m->execute( text => $scr_hello), $res_hello;
    is $m->compile( text => $scr_hello)->(), $res_hello;
}

######################################################################

SIMPLE_ONCE_BLOCK: {
    my $scr_hello = <<'ENDSCRIPT';
I'm sorry <% $name %>, I'm afraid I can't do that right now.
<%once>
  my $name = 'Dave';
</%once>
ENDSCRIPT

    my $res_hello = <<'ENDSCRIPT';
I'm sorry Dave, I'm afraid I can't do that right now.
ENDSCRIPT

    is $m->execute( text => $scr_hello), $res_hello;
    is $m->compile( text => $scr_hello)->(), $res_hello;
}

######################################################################

ONCE_AND_INIT_BLOCKS: {
    my $scr_count = <<'ENDSCRIPT';
The count is now <% $count %>.
<%once>
  my $count = 100;
</%once>
<%init>
  $count ++;
</%init>
ENDSCRIPT

    is $m->execute( text => $scr_count),     "The count is now 101.\n";
    is $m->compile( text => $scr_count)->(), "The count is now 101.\n";
    ok my $sub_count = $m->compile(text => $scr_count);
    is $sub_count->(), "The count is now 101.\n";
    is $sub_count->(), "The count is now 102.\n";
    is $sub_count->(), "The count is now 103.\n";
}

######################################################################
