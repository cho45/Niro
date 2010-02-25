#!/usr/bin/perl -w

use strict;
use Test::More tests => 17;

use_ok 'Text::MicroMason';

######################################################################

{
    ok my $m = Text::MicroMason->new();

    use vars qw( $sub_fib $count_fib );
    $count_fib = 0;
    my $scr_fib = q{<% my $x = shift; ++ $::count_fib; $x < 3 ? 1 : &$::sub_fib( $x - 1 ) + &$::sub_fib( $x - 2 ) %>};
    ok $sub_fib = $m->compile( text => $scr_fib );

    is $sub_fib->(10), 55;  # Fibonaci calculation works
    is $count_fib, 109;     # Without caching we need to do this a lot
}

######################################################################

{ 
    ok my $m = Text::MicroMason->new( -ExecuteCache );

    use vars qw( $sub_fib $count_fib );
    $count_fib = 0;
    my $scr_fib = q{<% my $x = shift; ++ $::count_fib; $x < 3 ? 1 : &$::sub_fib( $x - 1 ) + &$::sub_fib( $x - 2 ) %>};
    ok $sub_fib = $m->compile( text => $scr_fib );

    is $sub_fib->(10), 55;  # Fibonaci calculation works
    is $count_fib, 10;      # With caching we only do this a few times
}


######################################################################

{ 
    require Text::MicroMason::Cache::Null;
    ok my $m = Text::MicroMason->new( -ExecuteCache,
                                      execute_cache => Text::MicroMason::Cache::Null->new );

    use vars qw( $sub_fib $count_fib );
    $count_fib = 0;
    my $scr_fib = q{<% my $x = shift; ++ $::count_fib; $x < 3 ? 1 : &$::sub_fib( $x - 1 ) + &$::sub_fib( $x - 2 ) %>};
    ok $sub_fib = $m->compile( text => $scr_fib );

    is $sub_fib->(10), 55;  # Fibonaci calculation works
    is $count_fib, 109;     # Without caching we need to do this a lot
}


######################################################################

{
    ok my $m = Text::MicroMason->new( -ExecuteCache, -CompileCache );

    use vars qw( $sub_fib $count_fib );
    $count_fib = 0;
    my $scr_fib = q{<% my $x = shift; ++ $::count_fib; $x < 3 ? 1 : &$::sub_fib( $x - 1 ) + &$::sub_fib( $x - 2 ) %>};
    ok $sub_fib = sub { $m->execute( text => $scr_fib, @_ ) };

    is $sub_fib->(10), 55;  # Fibonaci calculation works
    is $count_fib, 10;      # With caching we only do this a few times
}

######################################################################
