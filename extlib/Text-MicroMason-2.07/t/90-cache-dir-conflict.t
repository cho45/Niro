#!/usr/bin/perl -w

use strict;
use Test::More tests => 12;

# Test the potential conflict between CompileCache and
# TemplateDir options

use_ok 'Text::MicroMason';

my $m1 = Text::MicroMason->new( -CompileCache, -TemplateDir, template_root => 'samples/' );
my $m2 = Text::MicroMason->new( -CompileCache, -TemplateDir, template_root => 'samples/subdir' );

######################################################################
#
# In the m2 object, using the samples/subdir, we should get an answer in German.

SUBDIR: {
    ok my $output = $m2->execute( file=>'test.msn', name=>'Sam', hour=>14);
    like ($output, qr/\QGuten Tag, Sam!\E/ );

    ok $output = $m2->execute( file=>'test.msn', name=>'Sam', hour=>10);
    like ($output, qr/\QGuten Morgen, Sam!\E/ );
}

# And, if we execute test.msn in m1, we should get an answer in English.

FILE: {
    ok my $output = $m1->execute( file=>'test.msn', name=>'Sam', hour=>14);
    like ($output, qr/\QGood afternoon, Sam!\E/ );

    ok $output = $m1->execute( file=>'test.msn', name=>'Sam', hour=>10);
    like ($output, qr/\QGood morning, Sam!\E/ );
}


my $m = Text::MicroMason->new( -TemplateDir, template_root => 'samples/' );

RELATIVE: {
    ok my $scr_hello = $m->execute( file => 'test-relative.msn', name => 'Dave');
    ok my $res_hello = "Test greeting:\nGood afternoon, Dave!\n";
    is ($m->execute(text=>$scr_hello), $res_hello );
}
