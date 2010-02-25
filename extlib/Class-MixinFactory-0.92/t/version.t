#!/usr/bin/perl

use Test;
BEGIN { plan tests => 3 }

use Class::MixinFactory;
ok( 1 );

eval "use Class::MixinFactory 0.001;";
ok( ! $@ );

eval "use Class::MixinFactory 2.0;";
ok( $@ );
