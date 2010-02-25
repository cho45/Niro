#!/usr/bin/perl -w

use strict;
use Test::More tests => 26;

use_ok 'Text::MicroMason';

######################################################################

LC: {
    ok my $m = Text::MicroMason->new( -PostProcess );
    ok $m->post_processors( sub { lc } );
    is $m->execute( text=>'Hello there!'), 'hello there!';
}

######################################################################

UC_NEW: {
    ok my $m = Text::MicroMason->new( -PostProcess, post_process => sub { uc } );
    is $m->execute( text=>'Hello there!' ), 'HELLO THERE!';
}

UC_PPMETH: {
    ok   my $m = Text::MicroMason->new( -PostProcess );
    ok $m->post_processors( sub { uc } );
    is $m->execute( text=>'Hello there!' ), 'HELLO THERE!';
}

UC_COMPILE: {
    ok my $m = Text::MicroMason->new( -PostProcess );
    ok my $subdef = $m->compile( text=>'Hello there!', post_process => sub { uc } );
    is $subdef->(), 'HELLO THERE!';
}

UC_EXECUTE: {
    ok my $m = Text::MicroMason->new( -PostProcess );
    is $m->execute( text=>'Hello there!', { post_process => sub { uc } } ), 'HELLO THERE!';
}

######################################################################

sub f1 {
    $_ = shift;
    tr/elo/apy/;
    $_;
}

sub f2 {
    $_ = shift;
    s/ello/ola/;
    s/wyrpd/birthday/;
    $_;
}

ORDERED_F1: {
    ok my $m = Text::MicroMason->new( -PostProcess, post_process => \&f1 );
    is $m->execute( text=>'Hello world!' ), 'Happy wyrpd!';
}

ORDERED_F2: {
    ok my $m = Text::MicroMason->new( -PostProcess, post_process => \&f2 );
    is $m->execute( text=>'Hello world!' ), 'Hola world!';
}

ORDERED_F1F2: {
    ok my $m = Text::MicroMason->new( -PostProcess, post_process => [ \&f1, \&f2 ] );
    is $m->execute( text=>'Hello world!' ), 'Happy birthday!';
}

ORDERED_F2F1: {
    ok my $m = Text::MicroMason->new( -PostProcess, post_process => [ \&f2, \&f1 ] );
    is $m->execute( text=>'Hello world!' ), 'Hypa wyrpd!';
}

######################################################################

sub naf1 () {
    tr/elo/apy/;
}

sub naf2 () {
    s/ello/ola/;
    s/wyrpd/birthday/;
}

EMPTY_PROTOTYPES: {
    ok my $m = Text::MicroMason->new( -PostProcess );
    ok $m->post_processors( \&naf1 );
    ok $m->post_processors( \&naf2 );
    is $m->execute( text=>'Hello world!' ), 'Happy birthday!';
}

######################################################################
