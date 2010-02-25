#!/usr/bin/perl -w

use strict;
use Test::More tests => 12;

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason->new( -CatchErrors );

######################################################################

FILE: {
    like $m->execute( file=>'samples/test.msn', name=>'Sam', hour => 14),
        qr/\QGood afternoon, Sam!\E/;
}

######################################################################

TAG: {
    my $scr_hello = "<& 'samples/test-recur.msn', name => 'Dave' &>";
    my $res_hello = "Test greeting:\n" . 'Good afternoon, Dave!' . "\n";
    is $m->execute(text=>$scr_hello), $res_hello;
}

######################################################################

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

    ok my $code = $m->compile(text => $script);
    ok my ( $output, $error ) = $m->execute( code=>$code, name => 'Sam', hour => 9);

    like $output, qr/\QGood morning, Sam!\E/;
    is $error, '';
    like $m->execute( code=>$code, name => 'Dave', hour => 23), 
        qr/\Qsorry Dave\E/;
}

######################################################################

HANDLE: {
    ok open my $TEST, '<', 'samples/test.msn';
    ok my $output = $m->execute( handle => $TEST, name=>'Sam', hour => 14);
    close $TEST;
    like $output, qr/\QGood afternoon, Sam!\E/;
}

######################################################################
