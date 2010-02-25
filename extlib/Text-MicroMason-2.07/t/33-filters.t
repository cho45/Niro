#!/usr/bin/perl -w

use strict;
use Test::More tests => 21;

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason->new( -Filters );

my $res_nofilter = 'Hello <"world">!';

######################################################################
# Test an expression inside a template using logical or.

is $m->execute( text => q(Var is <% $ARGS{foo} || 0 %>) ), "Var is 0";

######################################################################
# Test h encoding flag if we have HTML::Entities
SKIP: {
    skip "HTML::Entities is not installed", 4 
        unless HTML::Entities->can('encode');

    my $src_h = q(Hello <% '<"world">' |h %>!);
    my $res_h = 'Hello &lt;&quot;world&quot;&gt;!';

    is $m->execute(text => $src_h), $res_h, "Execute text with HTML::Entity filter";

    # Test h as a default filter
    {
        local $m->{default_filters} = 'h';
        my $src_h2 = q(Hello <% '<"world">' %>!);

        is $m->execute( text => $src_h2), $res_h, "Execute text with HTML::Entity default filter";

        # Explicitly disable the default filters
        my $src_h3 = q(Hello <% '<"world">' | n %>!);
        is $m->execute( text => $src_h3), $res_nofilter, "Execute text with HTML::Entity default turned off";
    }

    my $src_unh = qq(Hello <% '<"world">' |unh %>!);
    my $res_unh = 'Hello &lt;&quot;world&quot;&gt;!';
    is $m->execute( text => $src_unh), $res_unh, "Execute text with stacking h filter";
} # SKIP

######################################################################
# Test default u encoding flag if we have URI::Escape
SKIP: {
    skip "URI::Escape is not installed", 8
        unless URI::Escape->can('uri_escape');

    my $res_u = 'Hello %3C%22world%22%3E!';

    is $m->execute(text => qq(Hello <% '<"world">' |u %>!)), $res_u,
        "Execute text with URI::Escape filter";

    ok my $res = eval {$m->execute(text => qq(Hello <% '<"world">'|u %>!))},
        "Execute text with URI::Escape filter and no space";
    is $res, $res_u;

    # Test |u encoding flag in a file
    ok $res = eval {$m->execute(file => 'samples/test-filter.msn', msg => "foo")},
        "Execute text from file with URI::Escape filter and no space";
    is $res, "foo", "Filter execution error: $@";

    # Test u as a default filter
    {
        local $m->{default_filters} = 'u';
        my $src_u2 = qq(Hello <% '<"world">' %>!);
        is $m->execute( text => $src_u2), $res_u, "Execute text with URI::Escape default filter";

        # Explicitly disable the default filters
        my $src_u3 = qq(Hello <% '<"world">' | n %>!);
        my $res_u3 = 'Hello <"world">!';
        is $m->execute( text => $src_u3), $res_nofilter, "Execute text with URI::Escape default turned off";
    }

    # Test stacking and canceling with n
    my $res_hnu = 'Hello %3C%22world%22%3E!';  
    my $src_hnu = qq(Hello <% '<"world">' |hnu %>!);
    is $m->execute( text => $src_hnu), $res_hnu, "Execute text with stacking u filter";
}



######################################################################
# Test custom filters

sub f1 {
    $_ = shift;
    tr/elo/apy/;
    $_;
}

sub f2 {
    $_ = shift;
    s/wyrpd/birthday/;
    $_;
}

$m->filter_functions( f1 => \&f1 );
$m->filter_functions( f2 => \&f2 );

# Try one custom filter

my $src_custom1 = qq(<% 'hello <"world">' | f1 %>);
my $res_custom1 = qq(happy <"wyrpd">);
is $m->execute( text => $src_custom1), $res_custom1;

# Try two filters in order: they're order dependant, so this will fail
# if they execute in the wrong order.

my $src_custom2 = qq(<% 'hello <"world">' | f1 , f2 %>);
my $res_custom2 = qq(happy <"birthday">);
is $m->execute( text => $src_custom2), $res_custom2;


# Try both filters as defaults
{
    local $m->{default_filters} = 'f1, f2';
    my $src_custom3 = qq(<% 'hello <"world">' %>);
    is $m->execute( text => $src_custom3), $res_custom2;

    # Override default filters
    my $src_custom4 = qq(<% 'hello <"world">' |n, f1 %>);
    is $m->execute( text => $src_custom4), $res_custom1;
}


# Try one default filter and one additional filter
{
    local $m->{default_filters} = 'f1';
    my $src_custom3 = qq(<% 'hello <"world">' %>);
    is $m->execute( text => $src_custom3), $res_custom1;

    my $src_custom4 = qq(<% 'hello <"world">' | f2 %>);
    is $m->execute( text => $src_custom4), $res_custom2;
}

