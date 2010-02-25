#!/usr/bin/perl -w

use strict;

use Test::More;

if (eval { require Text::Balanced }) {
    plan tests => 18;
} else {
    plan skip_all => 'Text::Template emulator requires Text::Balanced';
}

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason->new( -TextTemplate );

######################################################################

my $scr_hello = <<'ENDSCRIPT';
Dear {$recipient},
Pay me at once.
      Love, 
	G.V.
ENDSCRIPT

my $res_hello = <<'ENDSCRIPT';
Dear King,
Pay me at once.
      Love, 
	G.V.
ENDSCRIPT

is $m->execute( text => $scr_hello, recipient => 'King' ), $res_hello;
is $m->compile( text => $scr_hello)->( recipient => 'King' ), $res_hello;

######################################################################

{
    no strict;

    $source = 'We will put value of $v (which is "good") here -> {$v}';
    $v = 'oops (main)';
    $Q::v = 'oops (Q)';
    $vars = { 'v' => \'good' };

    # (1) Build template from string
    ok $template = $m->compile( 'text' => $source );
    ok ref $template;

    # (2) Fill in template in anonymous package
    $result2 = 'We will put value of $v (which is "good") here -> good';
    ok $text = $template->(%$vars);
    is $text, $result2;

    # (3) Did we clobber the main variable?
    ok($v, 'oops (main)');

    # (4) Fill in same template again
    $result4 = 'We will put value of $v (which is "good") here -> good';
    ok $text = $template->(%$vars);
    is $text, $result4;

    # (5) Now with a package
    $result5 = 'We will put value of $v (which is "good") here -> good';
    ok $template = $m->new(package => 'Q')->compile( 'text' => $source );
    ok $text = $template->(%$vars);
    is $text, $result5;

    # (6) We expect to have clobbered the Q variable.
    is $Q::v, 'good';

    # (7) Now let's try it without a package
    $result7 = 'We will put value of $v (which is "good") here -> good';
    ok $template = $m->new()->compile( 'text' => $source );
    ok $text = $template->(%$vars);
    is $text, $result7;
}

######################################################################
