#!/usr/bin/perl -w

use strict;
use Test::More tests => 13;

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason::Base->new( -Sprintf );

######################################################################

{
  my $scr_hello = 'Hello %s!';
  my $res_hello = 'Hello World!';

  is $m->execute( text => $scr_hello, 'World'), $res_hello;
  is $m->compile( text => $scr_hello)->('World'), $res_hello;

  ok my $scriptlet = $m->compile( text => $scr_hello);
  is $scriptlet->('World'), $res_hello;
  is $scriptlet->('World'), $res_hello;
}

######################################################################

{
    my $scr_hello = <<'ENDSCRIPT';
Hello %s!
How are ya?
ENDSCRIPT

    my $res_hello = <<'ENDSCRIPT';
Hello World!
How are ya?
ENDSCRIPT

    is $m->execute( text => $scr_hello, 'World'), $res_hello;
    is $m->compile( text => $scr_hello)->('World'), $res_hello;

    ok my $scriptlet = $m->compile( text => $scr_hello);
    is $scriptlet->('World'), $res_hello;
    is $scriptlet->('World'), $res_hello;
}

######################################################################

{
  my $m = Text::MicroMason::Base->new( -Sprintf );
  my $res_hello = "Hello World!\n";

  is $m->execute( handle => \*DATA, 'World'), $res_hello;
}

######################################################################

__DATA__
Hello %s!
