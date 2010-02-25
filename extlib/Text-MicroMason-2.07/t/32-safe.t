#!/usr/bin/perl -w

use strict;
use Test::More tests => 23;

use_ok 'Text::MicroMason', qw( safe_compile safe_execute try_safe_compile try_safe_execute );

######################################################################

{
    my $scr_bold = '<b><% $ARGS{label} %></b>';
    is safe_compile($scr_bold)->(label => 'Foo'), '<b>Foo</b>';
    is safe_execute($scr_bold, label => 'Foo'), '<b>Foo</b>';
}

######################################################################

{
    my $scr_time = 'The time is <% time() %>';
    ok !try_safe_compile( $scr_time );
    ok !try_safe_execute( $scr_time );
}

######################################################################

{
    my $scr_time = 'The time is <% time() %>';
    my $safe = Safe->new();
    $safe->permit('time');
    ok try_safe_compile( $safe, $scr_time );
    ok try_safe_execute( $safe, $scr_time );
    ok safe_compile( $safe, $scr_time )->();
    ok safe_execute( $safe, $scr_time );
}

######################################################################

{
    local $^W; # no warnings uninitialized
    my $variable = 'secret';
    my $scr_hidden = '<% $variable %>';
    unlike try_safe_execute( $scr_hidden ), qr/secret/;
}

{
    local $^W;
    $main::variable = $main::variable = 'secret';
    my $scr_hidden = '<% $main::variable %>';
    unlike try_safe_execute( $scr_hidden ), qr/secret/;
}

{
    local $^W;
    $Foo::variable = $Foo::variable = 'secret';
    my $scr_hidden = '<% $Foo::variable %>';
    unlike try_safe_execute( $scr_hidden ), qr/secret/;
}

######################################################################

{
    my $scr_mobj = 'You\'ve been compiled by <% ref $m %>.';

    like safe_execute( $scr_mobj ), qr/Text::MicroMason::Safe::Facade/;
}

######################################################################

{
    my $script = qq| <& 'samples/test.msn', %ARGS &> |;

    my ($output, $err) = try_safe_execute($script, name => 'Sam', hour => 9);
    is $output, undef;
    like $err, qr/Can't call .*?execute/;
}

{
    my $m = Text::MicroMason->new( '-Safe' );
    my $script = qq| <& 'samples/test.msn', %ARGS &> |;

    my $output = eval{ $m->execute( text => $script, name => 'Sam', hour => 9)};
    is $output, undef;
    like $@, qr/Can't call .*?execute/;
}

{
    my $m = Text::MicroMason->new( '-Safe', safe_methods => 'execute' );
    my $script = qq| <& 'samples/test.msn', %ARGS &> |;

    my $output = eval{ $m->execute( text => $script, name => 'Sam', hour => 9)};
    ok length $output;
    ok !$@, "Execute produced error: $@";
}

my $safe_dir_mason = Text::MicroMason->class( 'Safe', 'TemplateDir' );
{
#  my $m = Text::MicroMason->new( '-Safe', safe_methods => 'execute',
#                                 -TemplateDir, template_root => 'samples', strict_root => 1 );
    my $m = Text::MicroMason->new(
                                  -TemplateDir, template_root => 'samples', strict_root => 1,
                                  '-Safe', safe_methods => 'execute',
                                 );
    my $script = qq| <& 'test.msn', %ARGS &> |;

    my $output = eval{ $m->execute( text => $script, name => 'Sam', hour => 9)};
    ok length $output;
    ok !$@, "Execute produced error: $@";
}

{
    my $m = Text::MicroMason->new( '-Safe', safe_methods => 'execute',
                                   -TemplateDir, template_root => 'samples', strict_root => 1 );
    my $script = qq| <& '../MicroMason.pm', %ARGS &> |;

    my $output = eval{ $m->execute( text => $script, name => 'Sam', hour => 9)};
    is $output, undef;
    like $@, qr/required base path/;
}

######################################################################
