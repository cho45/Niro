#!/usr/bin/perl -w

use strict;
use Test::More tests => 105;

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason->new();

######################################################################

FLOW_CONTROL: {

    my $scr_rand = <<'ENDSCRIPT';
% if ( int rand 2 ) {
  Hello World!
% } else {
  Goodbye Cruel World!
% }
ENDSCRIPT

  my $scriptlet = $m->compile( text => $scr_rand);

  for ( 0 .. 99 ) {
      like $scriptlet->(), qr/^  (Hello|Goodbye Cruel) World!\n$/;
  }
}

######################################################################

PERL_BLOCK: {
  
    my $scr_count = <<'ENDSCRIPT';
Counting...
<%perl>
  foreach ( 1 .. 9 ) {
     $_out->( $_ )
  }
</%perl>
Done!
ENDSCRIPT

    my $res_count = <<'ENDSCRIPT';
Counting...
123456789Done!
ENDSCRIPT

  is $m->execute( text => $scr_count), $res_count;
}

SPANNING_PERL: {

    my $scr_count = <<'ENDSCRIPT';
<table><tr>
<%perl> foreach ( 1 .. 9 ) { </%perl>
  <td><b><% $_ %></b></td>
<%perl> } </%perl>
</tr></table>
ENDSCRIPT

    my $res_count = <<'ENDSCRIPT';
<table><tr>
  <td><b>1</b></td>
  <td><b>2</b></td>
  <td><b>3</b></td>
  <td><b>4</b></td>
  <td><b>5</b></td>
  <td><b>6</b></td>
  <td><b>7</b></td>
  <td><b>8</b></td>
  <td><b>9</b></td>
</tr></table>
ENDSCRIPT

    is $m->execute( text => $scr_count), $res_count;

}

######################################################################

SUBTEMPLATE: {
    my $scr_closure = <<'ENDSCRIPT';
% my $draw_item = sub {
%   my $item = shift;
<p><b><% $item %></b><br>
  <a href="/more?item=<% $item %>">Find out more about <% $item %>.</p>
% };
<h1>We've Got Items!</h1>
% foreach my $item ( qw( Foo Bar Baz ) ) {
%   $draw_item->( $item );
% }
ENDSCRIPT

    my $res_closure = <<'ENDSCRIPT';
<h1>We've Got Items!</h1>
<p><b>Foo</b><br>
  <a href="/more?item=Foo">Find out more about Foo.</p>
<p><b>Bar</b><br>
  <a href="/more?item=Bar">Find out more about Bar.</p>
<p><b>Baz</b><br>
  <a href="/more?item=Baz">Find out more about Baz.</p>
ENDSCRIPT

    ok( $m->execute( text => $scr_closure), $res_closure );
}

######################################################################
