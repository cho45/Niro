#!/usr/bin/perl -w

use strict;
use Text::MicroMason;

use Test::More tests => 46;
use File::Copy;
use Carp;
$SIG{__DIE__} = \&Carp::confess;

######################################################################

{
    ok my $m = Text::MicroMason->new();

    use vars qw( $count_sub $sub_count $local_count );
    $sub_count = 0;
    $local_count = 0;
    my $count_scr = q{<%once> ++ $::sub_count; my $count; </%once><%perl> ++ $::local_count; </%perl><% ++ $count; %>};
    for ( 1 .. 3 ) { 
        $count_sub = $m->compile( text => $count_scr );
        for ( 1 .. 3 ) { 
            $count_sub->($_);
        }
    }

    is $sub_count, 3;
    is $local_count, 9;
    is $count_sub->(), 4;
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -CompileCache );

    use vars qw( $count_sub $sub_count $local_count );
    $sub_count = 0;
    $local_count = 0;
    my $count_scr = q{<%once> ++ $::sub_count; my $count; </%once><%perl> ++ $::local_count; </%perl><% ++ $count; %>};
    for ( 1 .. 3 ) { 
        $count_sub = $m->compile( text => $count_scr );
        for ( 1 .. 3 ) { 
            $count_sub->($_);
        }
    }

    is $sub_count, 1;
    is $local_count, 9;
    is $count_sub->(), 10;
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -CompileCache, -ExecuteCache );

    use vars qw( $count_sub $sub_count $local_count );
    $sub_count = 0;
    $local_count = 0;
    my $count_scr = q{<%once> ++ $::sub_count; my $count; </%once><%perl> ++ $::local_count; </%perl><% ++ $count; %>};
    for ( 1 .. 3 ) { 
        $count_sub = $m->compile( text => $count_scr );
        for ( 1 .. 3 ) { 
            $count_sub->($_);
        }
    }

    is $sub_count, 1;
    is $local_count, 3;
    is $count_sub->(), 4;
}

######################################################################

{
    ok my $m = Text::MicroMason->new( -ExecuteCache, -CompileCache );

    use vars qw( $count_sub $sub_count $local_count );
    $sub_count = 0;
    $local_count = 0;
    my $count_scr = q{<%once> ++ $::sub_count; my $count; </%once><%perl> ++ $::local_count; </%perl><% ++ $count; %>};
    for ( 1 .. 3 ) { 
        $count_sub = $m->compile( text => $count_scr );
        for ( 1 .. 3 ) { 
            $count_sub->($_);
        }
    }

    is $sub_count, 1;
    is $local_count, 3;
    is $count_sub->(), 4;
}

######################################################################

# Test using $m->execute directly: This should compile and run it
# properly.  Running execute 10 times is like running compile once,
# then calling the resulting sub 10 times.

{
    ok my $m = Text::MicroMason->new( -CompileCache );

    use vars qw( $count_sub $sub_count $local_count );
    $sub_count = 0;
    $local_count = 0;
    my $count_scr = q{<%once> ++ $::sub_count; my $count; </%once><%perl> ++ $::local_count; </%perl><% ++ $count; %>};
    for ( 1 .. 10 ) {
        $m->execute( text => $count_scr );
    }

    is $sub_count, 1;
    is $local_count, 10;
}

######################################################################

# Test using $m->execute directly, on a file.

{
    ok my $m = Text::MicroMason->new( -CompileCache );

    use vars qw( $count_sub $sub_count $local_count );
    $sub_count = 0;
    $local_count = 0;

    for ( 1 .. 10 ) {
        ok $m->execute( file => "samples/t-counter.msn" );
    }

    is $sub_count, 1;
    is $local_count, 10;
}


######################################################################

# Testss submitted via rt.cpan.org by Jon Warbrick on #21802

copy('samples/t-counter.msn','samples/t34a.msn');

######################################################################

# Test cache expiration using $m->execute directly on a file

{
    ok my $m = Text::MicroMason->new( -CompileCache );

    use vars qw( $count_sub $sub_count $local_count );
    $sub_count = 0;
    $local_count = 0;

    my $time = time-5;
    utime $time, $time, "samples/t34a.msn";
    for ( 1 .. 2 ) {
        ok $m->execute( file => "samples/t34a.msn" );
    }
    $time = time;
    utime $time, $time, "samples/t34a.msn";
    sleep 2; # to defeat not checking more than once per second
    for ( 1 .. 2 ) {
        ok $m->execute( file => "samples/t34a.msn" );
    }

    is $sub_count, 2;
    is $local_count, 4;
}

######################################################################

# Test cache expiration using $m->execute directly on a file, using -TemplateDir

{
    ok my $m = Text::MicroMason->new( -CompileCache, 
                                      -TemplateDir, template_root => 'samples'  );

    use vars qw( $count_sub $sub_count $local_count );
    $sub_count = 0;
    $local_count = 0;

    my $time = time-5;
    utime $time, $time, "samples/t34a.msn";
    for ( 1 .. 2 ) {
        ok $m->execute( file => "t34a.msn" );
    }
    $time = time;
    utime $time, $time, "samples/t34a.msn";
    sleep 2; # to defeat not checking more than once per second; sleep 1 triggered false cpants fail
    for ( 1 .. 2 ) {
        ok $m->execute( file => "t34a.msn" );
    }

    is $sub_count, 2;
    is $local_count, 4;
}

######################################################################

unlink('samples/t34a.msn');
