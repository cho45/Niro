#!/usr/bin/perl -w

use strict;
use Test::More tests => 112;

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason->new( -PLP );

######################################################################

my $scr_hello = <<'ENDSCRIPT';
<: my $noun = 'World'; :>Hello <:= $noun :>!
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

######################################################################

my $scr_bold = '<b><:= $ARGS{label} :></b>';
is $m->execute( text => $scr_bold, label=>'Foo'), '<b>Foo</b>';
is $m->compile( text => $scr_bold)->(label=>'Foo'), '<b>Foo</b>';

######################################################################

FLOW_CONTROL: {

    my $scr_rand = <<'ENDSCRIPT';
<: if ( int rand 2 ) { :>
  Hello World!
<: } else { :>
  Goodbye Cruel World!
<: } :>
ENDSCRIPT

  my $scriptlet = $m->compile(text => $scr_rand);

  for (0 .. 99) {
      like $scriptlet->(), qr/^\n  (Hello World!|Goodbye Cruel World!)\n$/;
  }
}

######################################################################

PERL_BLOCK: {
  
    my $scr_count = <<'ENDSCRIPT';
Counting...
<:
  foreach ( 1 .. 9 ) {
     $_out->( $_ )
  }
:>
Done!
ENDSCRIPT

    my $res_count = <<'ENDSCRIPT';
Counting...
123456789
Done!
ENDSCRIPT

    is $m->execute( text => $scr_count), $res_count;

}

SPANNING_PERL: {

    my $scr_count = <<'ENDSCRIPT';
<table><tr>
<: foreach ( 1 .. 9 ) { :>  <td><b><:= $_ :></b></td>
<: } :></tr></table>
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
