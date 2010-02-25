#!/usr/bin/perl -w

use strict;
use Test::More tests => 9;

use_ok 'Text::MicroMason', qw( safe_compile safe_execute try_safe_compile try_safe_execute );

######################################################################

use Text::MicroMason qw( try_execute_file try_compile try_execute );

FILE: {
    my $output = try_execute_file('samples/test.msn', name=>'Sam', hour=>14);
    like $output, qr/\QGood afternoon, Sam!\E/;
}

SYNTAX: {
    my $script = <<'TEXT_END';

<%perl>
  my $hour = $ARGS{hour};
</%perl> xx
% if ( $ARGS{name} eq 'Dave' and $hour > 22 ) {
  I'm sorry <% $ARGS{name} %>, I'm afraid I can't do that right now.
% } else {
  <& 'samples/test.msn', name => $ARGS{name}, hour => $hour &>
% }
TEXT_END

    ok my $code = try_compile($script);
    ok my $output = try_execute($code, name => 'Sam', hour => 9);
    like $output, qr/\QGood morning, Sam!\E/;
    ok $output = try_execute($code, name => 'Dave', hour => 23);
    like $output, qr/\Qsorry Dave\E/;
}

FILE_IS_NOT_SAFE: {
    my $script = qq| <& 'samples/test.msn', %ARGS &> |;

    my ($output, $err) = try_safe_execute($script, name => 'Sam', hour => 9);
    is $output, undef;
    like $err, qr/in this compartment/;
}

