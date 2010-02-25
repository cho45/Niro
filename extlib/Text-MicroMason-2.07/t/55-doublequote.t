#!/usr/bin/perl -w

use strict;
use Test::More tests => 20;

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason::Base->new( -DoubleQuote );

######################################################################

{
    my $scr_hello = 'Hello $ARGS{noun}!';
    my $res_hello = 'Hello World!';

    is $m->execute( text => $scr_hello, noun => 'World'), $res_hello;
    is $m->compile( text => $scr_hello)->(noun => 'World'), $res_hello;

    ok my $scriptlet = $m->compile( text => $scr_hello);
    is $scriptlet->(noun => 'World'), $res_hello;
    is $scriptlet->(noun => 'World'), $res_hello;
}

######################################################################

{
    my $scr_hello = <<'ENDSCRIPT';
${ $::noun = 'World'; \( "" ) }Hello $::noun!
How are ya?
ENDSCRIPT

    my $res_hello = <<'ENDSCRIPT';
Hello World!
How are ya?
ENDSCRIPT

    is $m->execute( text => $scr_hello, noun => 'World'), $res_hello;
    is $m->compile( text => $scr_hello)->(noun => 'World'), $res_hello;

    ok my $scriptlet = $m->compile( text => $scr_hello);
    is $scriptlet->(noun => 'World'), $res_hello;
    is $scriptlet->(noun => 'World'), $res_hello;
}

######################################################################

{
    ok my $m = Text::MicroMason::Base->new( -DoubleQuote, -PassVariables );

    my $scr_hello = 'Hello $noun!';
    my $res_hello = 'Hello World!';

    is $m->execute( text => $scr_hello, noun => 'World'), $res_hello;
    is $m->compile( text => $scr_hello)->(noun => 'World'), $res_hello;

    ok my $scriptlet = $m->compile( text => $scr_hello);
    is $scriptlet->(noun => 'World'), $res_hello;
    is $scriptlet->(noun => 'World'), $res_hello;
}

######################################################################

{
    ok my $m = Text::MicroMason::Base->new( -DoubleQuote, -PassVariables );
    my $res_hello = "Hello World!\n";

    is $m->execute( handle => \*DATA, noun => 'World'), $res_hello;
}

######################################################################

__DATA__
Hello $noun!
