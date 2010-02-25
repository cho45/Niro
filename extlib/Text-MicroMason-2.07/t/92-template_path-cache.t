#!/usr/bin/perl -w
use strict;
use Test::More tests => 9;

use_ok 'Text::MicroMason';

# Test TemplatePath with CompileCache

######################################################################
#
# Compile and cache test-relative.msn with one path. Executing it again
# with a different path should get us different results.

my $m1 = Text::MicroMason->new( -CompileCache,
                                -TemplatePath, template_path => [ qw(samples/subdir/ samples/) ]);
PATH1: {
    ok (my $scr_hello = $m1->execute( file => 'test-relative.msn', name => 'Dave'));
    ok (my $res_hello = "Test greeting:\nGuten Tag, Dave!\n");
    like ($scr_hello, qr/\Q$res_hello\E/);
    like ($m1->execute(text => $scr_hello), qr/\Q$res_hello\E/);
}

my $m2 = Text::MicroMason->new( -CompileCache,
                                -TemplatePath, template_path => [ qw(samples/ samples/subdir/) ]);

PATH2: {
    ok (my $scr_hello = $m2->execute( file => 'test-relative.msn', name => 'Dave'));
    ok (my $res_hello = "Test greeting:\nGood afternoon, Dave!\n");
    like ($scr_hello, qr/\Q$res_hello\E/);
    like ($m2->execute(text => $scr_hello), qr/\Q$res_hello\E/);
}


