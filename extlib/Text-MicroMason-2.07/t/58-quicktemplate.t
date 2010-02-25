#!/usr/bin/perl -w

use strict;
use Test::More tests => 22;

use Text::MicroMason::QuickTemplate; # to import $DONTSET

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason->new( -QuickTemplate );

######################################################################

my $scr_hello = <<'ENDSCRIPT';
Dear {{to}},
    Have a {{day_type}} day.
Your {{relation}},
{{from}}
ENDSCRIPT

my $res_hello = <<'ENDSCRIPT';
Dear Professor Dumbledore,
    Have a swell day.
Your friend,
Harry
ENDSCRIPT

ok my $scriptlet = $m->compile(text => $scr_hello);
is $scriptlet->(to       => 'Professor Dumbledore',
                relation => 'friend',
                day_type => 'swell',
                from     => 'Harry',), 
    $res_hello;

is $scriptlet->( { to       => 'Professor Dumbledore',
         relation => 'friend',
         day_type => 'swell',
         from     => 'Harry', } ), 
    $res_hello;

######################################################################

ok my $emulator = $m->new(text => $scr_hello);
is $emulator->fill( { to       => 'Professor Dumbledore',
                      relation => 'friend',
                      day_type => 'swell',
                      from     => 'Harry', } ), 
    $res_hello;

######################################################################

ok my $book_t = $emulator->new( text => '<i>{{title}}</i>, by {{author}}' );

ok my $bibl_1 = $book_t->fill({author => "Stephen Hawking",
                               title  => "A Brief History of Time"});
is $bibl_1, "<i>A Brief History of Time</i>, by Stephen Hawking";

ok my $bibl_2 = $book_t->fill({author => "Dr. Seuss",
                               title  => "Green Eggs and Ham"});
is $bibl_2, "<i>Green Eggs and Ham</i>, by Dr. Seuss";

######################################################################

is eval { $book_t->fill({author => 'Isaac Asimov'}) }, undef;
like $@, qr/could not resolve the following symbol: title/;

######################################################################

ok my $bibl_4 = $book_t->fill({author => 'Isaac Asimov',
                               title  => $Text::MicroMason::QuickTemplate::DONTSET });
is $bibl_4, "<i>{{title}}</i>, by Isaac Asimov";

######################################################################

ok $m->compile( text => $scr_hello);
ok $m->pre_fill(to       => 'Professor Dumbledore',
                relation => 'friend' );

is eval { $m->fill(); 1 }, undef;
ok $@;

ok $m->pre_fill( day_type => 'swell',
                  from     => 'Harry');
is $m->fill(), $res_hello;

######################################################################
