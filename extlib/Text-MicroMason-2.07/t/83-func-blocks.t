#!/usr/bin/perl -w

use strict;
use Test::More tests => 22;

use_ok 'Text::MicroMason', qw( compile execute );

######################################################################

SIMPLE_ARGS: {
    my $scr_bold = '<%args>$label</%args><b><% $label %></b>';
    is execute($scr_bold, label=>'Foo'), '<b>Foo</b>';
    is compile($scr_bold)->(label=>'Foo'), '<b>Foo</b>';
    is eval { execute($scr_bold); 1 }, undef;
    ok $@;
}

######################################################################

ARGS_BLOCK_WITH_DEFAULT: {
    my $scr_hello = <<'ENDSCRIPT';
<%args>
  $name
  $hour => (localtime)[2]
</%args>
% if ( $name eq 'Dave' ) {
  I'm sorry <% $name %>, I'm afraid I can't do that right now.
% } else {
  <%perl>
    my $greeting = ( $hour > 11 ) ? 'afternoon' : 'morning'; 
  </%perl>
  Good <% $greeting %>, <% $name %>!
% }
ENDSCRIPT

    my $res_hello = <<'ENDSCRIPT';
    Good afternoon, World!
ENDSCRIPT

    is execute($scr_hello, name => 'World', hour => 13), $res_hello;
    is compile($scr_hello)->(name => 'World', hour => 13), $res_hello;
    like execute($scr_hello, name => 'World'), qr/Good (afternoon|morning), World!/;
    is eval { execute($scr_hello, hour => 13); 1 }, undef;
    ok $@;
    is eval { execute($scr_hello); 1 }, undef;
    ok $@;
}

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

    is execute($scr_hello), $res_hello;
    is compile($scr_hello)->(), $res_hello;
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

    is execute($scr_hello), $res_hello;
    is compile($scr_hello)->(), $res_hello;
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

    is execute($scr_count),     "The count is now 101.\n";
    is compile($scr_count)->(), "The count is now 101.\n";
    ok my $sub_count = compile($scr_count);
    is $sub_count->(), "The count is now 101.\n";
    is $sub_count->(), "The count is now 102.\n";
    is $sub_count->(), "The count is now 103.\n";
}
