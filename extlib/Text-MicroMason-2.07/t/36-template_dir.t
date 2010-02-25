#!/usr/bin/perl -w

use strict;
use Test::More tests => 6;

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason->new( -CatchErrors, -TemplateDir, template_root => 'samples/' );

######################################################################

FILE: {
    like $m->execute( file=>'test.msn', name=>'Sam', hour => 14),
        qr/\QGood afternoon, Sam!\E/;
}

######################################################################

TAG: {
    my $scr_hello = "<& 'test-relative.msn', name => 'Dave' &>";
    my $res_hello = "Test greeting:\n" . 'Good afternoon, Dave!' . "\n";
    is $m->execute(text=>$scr_hello), $res_hello;
}

######################################################################

BASE: {
    ok my $m = Text::MicroMason->new( -CatchErrors, -TemplateDir );
    my $scr_hello = "<& 'samples/test-relative.msn', name => 'Dave' &>";
    my $res_hello = "Test greeting:\n" . 'Good afternoon, Dave!' . "\n";
    is $m->execute(text=>$scr_hello), $res_hello;
}

######################################################################
