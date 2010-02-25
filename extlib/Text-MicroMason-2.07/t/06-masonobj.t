#!/usr/bin/perl -w

use strict;
use Test::More tests => 3;

use_ok 'Text::MicroMason';
ok my $m = Text::MicroMason->new();

######################################################################

{
    my $scr_mobj = 'You\'ve been compiled by <% ref $m %>.';
    my $res_mobj = 'You\'ve been compiled by Text::MicroMason';

    like $m->execute( text => $scr_mobj), qr/^\Q$res_mobj\E/;
}

######################################################################

