#!/usr/bin/perl -w

use strict;
use Test::More tests => 11;

use_ok 'Text::MicroMason', qw( safe_compile safe_execute try_safe_compile try_safe_execute );

######################################################################

my $scr_bold = '<b><% $ARGS{label} %></b>';
is (safe_compile($scr_bold)->(label=>'Foo'), '<b>Foo</b>');
is (safe_execute($scr_bold, label=>'Foo'), '<b>Foo</b>');
  
my $scr_time = 'The time is <% time() %>';
is try_safe_compile( $scr_time ), undef;
is try_safe_execute( $scr_time ), undef;

ok my $safe = Safe->new();
ok $safe->permit('time');
ok (try_safe_compile( $safe, $scr_time ));
ok (try_safe_execute( $safe, $scr_time ));
ok (safe_compile( $safe, $scr_time )->());
ok (safe_execute( $safe, $scr_time ));

