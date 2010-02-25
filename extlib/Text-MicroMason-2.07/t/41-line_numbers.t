#!/usr/bin/perl -w

use strict;
use Test::More tests => 33;

use_ok 'Text::MicroMason';

######################################################################

{
    ok my $m = Text::MicroMason->new( -LineNumbers );
    ok my $output = eval { $m->execute( text=>'Hello <% $_[0] %>!', 'world' ) };
    is $@, '';
    is $output, 'Hello world!';
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -LineNumbers );
    ok my $output = eval { $m->interpret( text=>'1' ) };
    is $@, '';
    like $output, qr{# line 0 "text template [(]compiled at \S+line_numbers.t line \d+[)]"};
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -LineNumbers );
    is eval { $m->execute( text=>'Hello <% $__[] %>!', 'world' ) }, undef;
    like $@,  qr{requires explicit package name at text template [(]compiled at \S+.t line \d+[)] line 1};
}

{
    ok my $m = Text::MicroMason->new( -LineNumbers );

    is eval { $m->execute( text=> "\n\n" . 'Hello <% $__[] %>!', 'world' ) }, undef;
    like $@, qr{requires explicit package name at text template [(]compiled at \S+.t line \d+[)] line 3};
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -LineNumbers );
    ok my $output = eval { $m->execute( inline=>'Hello <% $_[0] %>!', 'world' ) };
    is $@, '';
    is $output, 'Hello world!';
}

{
    ok my $m = Text::MicroMason->new( -LineNumbers );
    ok my $output = eval { $m->interpret( inline=>'1' ) };
    is $@, '';
    like $output,  qr{# line \d+ "\S+line_numbers.t"};
}

{
    ok my $m = Text::MicroMason->new( -LineNumbers );
    is eval { $m->execute( inline => 'Hello <% $__[] %>!', 'world' ) }, undef; my $line = __LINE__;
    like $@, qr{requires explicit package name at \S+.t line \Q$line\E};
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -LineNumbers );
    ok my $output = eval { $m->execute( file=>'samples/test.msn', name=>'Sam', hour=>14 ) };
    is $@, '';
    like $output, qr/\QGood afternoon, Sam!\E/;
}

{
    ok my $m = Text::MicroMason->new( -LineNumbers );
    is eval { $m->execute( file=>'samples/die.msn' ) }, undef;
    is $@, "MicroMason execution failed: Foo! at samples/die.msn line 1.\n";
}

######################################################################
