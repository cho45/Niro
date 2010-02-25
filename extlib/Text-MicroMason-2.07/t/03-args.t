#!/usr/bin/perl -w

use strict;
use Test::More tests => 23;

use_ok 'Text::MicroMason';
ok my $m = Text::MicroMason->new();

######################################################################

{
    my $scr_hello = "Hello <% shift(@_) %>!";
    my $res_hello = "Hello World!";

    is $m->execute( text => $scr_hello, 'World' ), $res_hello;
    is $m->compile( text => $scr_hello)->( 'World' ), $res_hello;
}

######################################################################

{
    my $scr_bold = '<b><% $ARGS{label} %></b>';
    is $m->execute( text => $scr_bold, label=>'Foo'), '<b>Foo</b>';
    is $m->compile( text => $scr_bold)->(label=>'Foo'), '<b>Foo</b>';
}

######################################################################

SIMPLE_ARGS: {
    my $scr_bold = '<%args>$label</%args><b><% $label %></b>';
    is $m->execute( text => $scr_bold, label=>'Foo'), '<b>Foo</b>';
    is $m->compile( text => $scr_bold)->(label=>'Foo'), '<b>Foo</b>';
    is eval { $m->execute( text => $scr_bold); 1 }, undef;
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

    is $m->execute( text => $scr_hello, name => 'World', hour => 13), $res_hello;
    is $m->compile( text => $scr_hello)->(name => 'World', hour => 13), $res_hello;
    like $m->execute( text => $scr_hello, name => 'World'), qr/Good (afternoon|morning), World!/;
    is eval { $m->execute( text => $scr_hello, hour => 13); 1 }, undef;
    is eval { $m->execute( text => $scr_hello); 1 }, undef;
}

######################################################################

ARGS_BLOCK_WITH_DEFAULT_LIST: {
    my $scr_count = <<'ENDSCRIPT';
<%args>
 @data => ()
</%args>
Count: <% scalar @data %>
ENDSCRIPT

    my $res_count_0 = "Count: 0\n";
    my $res_count_1 = "Count: 1\n";
    my $res_count_2 = "Count: 2\n";

    is $m->execute( text => $scr_count ), $res_count_0;
    is $m->execute( text => $scr_count, data => [] ), $res_count_0;
    is $m->execute( text => $scr_count, data => [ 1 ] ), $res_count_1;
    is $m->execute( text => $scr_count, data => [ 1 .. 2 ] ), $res_count_2;
}

######################################################################

ARGS_BLOCK_WITH_DEFAULT_LIST: {
    my $scr_count = <<'ENDSCRIPT';
<%args>
 @data => ( 1 )
</%args>
Count: <% scalar @data %>
ENDSCRIPT

    my $res_count_0 = "Count: 0\n";
    my $res_count_1 = "Count: 1\n";
    my $res_count_2 = "Count: 2\n";

    is $m->execute( text => $scr_count ), $res_count_1;
    is $m->execute( text => $scr_count, data => [] ), $res_count_0;
    is $m->execute( text => $scr_count, data => [ 1 ] ), $res_count_1;
    is $m->execute( text => $scr_count, data => [ 1 .. 2 ] ), $res_count_2;
}

######################################################################

