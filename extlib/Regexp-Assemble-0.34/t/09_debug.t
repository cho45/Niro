# 09_debug.t
#
# Test suite for Regexp::Assemble
# Exercise the debug parts
#
# copyright (C) 2006-2007 David Landgren

use strict;

eval qq{use Test::More tests => 68};
if( $@ ) {
    warn "# Test::More not available, no tests performed\n";
    print "1..1\nok 1\n";
    exit 0;
}

use Regexp::Assemble;

my $fixed = 'The scalar remains the same';
$_ = $fixed;

{
    my $r = Regexp::Assemble->new( debug => 15 );
    is( $r->{debug}, 15, 'debug new(n)' );
    $r->debug( 0 );
    is( $r->{debug}, 0, 'debug(0)' );
    $r->debug( 4 );
    is( $r->{debug}, 4, 'debug(4)' );
    $r->debug();
    is( $r->{debug}, 0, 'debug()' );
}

{
    my $u = Regexp::Assemble->new(unroll_plus => 1)->debug(4);
    my $str;

    $u->add( "[a]", );
    $str = $u->as_string;
    is( $str, 'a', '[a] -> a' );

    $u->add( "a+b", 'ac' );
    $str = $u->as_string;
    is( $str, 'a(?:a*b|c)', 'unroll plus a+b ac' );

    $u->add( "\\LA+B", "ac" );
    $str = $u->as_string;
    is( $str, 'a(?:a*b|c)', 'unroll plus \\LA+B ac' );

    $u->add( '\\Ua+?b', "AC" );
    $str = $u->as_string;
    is( $str, 'A(?:A*?B|C)', 'unroll plus \\Ua+?b AC' );

    $u->add( "\\d+d", "\\de" );
    $str = $u->as_string;
    is( $str, '\\d(?:\d*d|e)', 'unroll plus \\d+d \\de' );

    $u->add( "\\xab+f", "\\xabg" );
    $str = $u->as_string;
    is( $str, "\xab(?:\xab*f|g)", 'unroll plus \\xab+f \\xabg' );

    $u->add( "[a-e]+h", "[a-e]i" );
    $str = $u->as_string;
    is( $str, "[a-e](?:[a-e]*h|i)", 'unroll plus [a-e]+h [a-e]i' );

    $u->add( "a+b" );
    $str = $u->as_string;
    is( $str, "a+b", 'reroll a+b' );

    $u->add( "a+b", "a+" );
    $str = $u->as_string;
    is( $str, "a+b?", 'reroll a+b?' );

    $u->add( "a+?b", "a+?" );
    $str = $u->as_string;
    is( $str, "a+?b?", 'reroll a+?b?' );

    $u->add( qw(defused fused used) );
    $str = $u->as_string;
    is( $str, "(?:(?:de)?f)?used", 'big debug block in _insert_path()' );
}

{
    my $str = '\t+b*c?\\x41';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\t+', 'b*', 'c?', 'A' ],
        "_lex $str",
    );

    $str = '\Q[';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\\[' ],
        "_lex $str",
    );

    $str = '\Q]';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\\]' ],
        "_lex $str",
    );

    $str = '\Q(';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\\(' ],
        "_lex $str",
    );

    $str = '\Q)';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\\)' ],
        "_lex $str",
    );

    $str = '\Qa+b*c?';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ 'a', '\+', 'b', '\*', 'c', '\?' ],
        "_lex $str",
    );

    $str = 'a\\LBC\\Ude\\Ef\\Qg+';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str  ),
        [ 'a', 'b', 'c', 'D', 'E', 'f', 'g', '\\+' ],
        "_lex $str",
    );

    $str = 'a\\uC';
    is_deeply( Regexp::Assemble->new(debug => 4) ->_lex( $str  ),
        [ 'a', 'C' ],
        "_lex $str",
    );

    $str = '\Q\/?';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str  ), [ '\/', '\?' ], "_lex $str" );

    $str = 'p\\L\\QA+\\EZ';
    is_deeply( Regexp::Assemble->new->debug(4)->add( $str )->_path,
        [ 'p', 'a', '\\+', 'Z' ], "add $str" );

    $str = '^\Qa[b[';
    is_deeply( Regexp::Assemble->new->debug(15)->add( $str )->_path,
        [ '^', 'a', '\\[', 'b', '\\[' ], "add $str" );
}

{
    my $r = Regexp::Assemble->new->debug(4)->add('\x45');
    is_deeply( $r->_path, [ 'E' ], '_lex(\\x45) with debug' );
}

{
    my $ra = Regexp::Assemble->new(debug => 1);
    $ra->insert( undef );
    is_deeply( $ra->_path, [{'' => undef}], 'insert(undef)' );
}

{
    my $r = Regexp::Assemble->new(lex => '\\d');
    is_deeply( $r->debug(4)->add( '67abc123def+' )->_path,
        [ '6', '7', 'abc', '1', '2', '3', 'def+' ],
        '67abc123def+ with \\d lexer',
    );
    is_deeply( $r->reset->debug(0)->add( '67ab12de+' )->_path,
        [ '6', '7', 'ab', '1', '2', 'de+' ],
        '67ab12de+ with \\d lexer',
    );
}

{
    my $r = Regexp::Assemble->new(lex => '\\d');
    is_deeply( $r->debug(4)->add( '67\\Q1a*\\E12jk' )->_path,
        [ '6', '7', '1', 'a', '\\*', '1', '2', 'jk' ],
        '67\\Q1a*\\E12jk with \\d lexer',
    );
}

{
    my $r = Regexp::Assemble->new(lex => '\\d');
    is_deeply( $r->debug(4)->add( '67\\Q1a*45k+' )->_path,
        [ '6', '7', '1', 'a', '\\*', '4', '5', 'k', '\\+' ],
        '67\\Q1a*45k+ with \\d lexer',
    );
}

{
    my $r = Regexp::Assemble->new(lex => '\\d');
    is_deeply( $r->debug(4)->add( '7\U6a' )->_path,
        [ '7', '6', 'A' ],
        '7\\U6a with \\d lexer',
    );
}

{
    my $r = Regexp::Assemble->new(lex => '\\d');
    is_deeply( $r->debug(4)->add( '8\L9C' )->_path,
        [ '8', '9', 'c' ],
        '8\\L9C with \\d lexer',
    );
}

{
    my $r = Regexp::Assemble->new(lex => '\\d');
    is_deeply( $r->debug(4)->add( '57\\Q2a+23d+' )->_path,
        [ '5', '7', '2', 'a', '\\+', '2', '3', 'd', '\\+' ],
        '57\\Q2a+23d+ with \\d lexer',
    );
}

{
    my $save = $Regexp::Assemble::Default_Lexer;
    Regexp::Assemble::Default_Lexer('\\d');
    my $r = Regexp::Assemble->new;
    is_deeply( $r->debug(4)->add( '67\\Uabc\\E123def' )->_path,
        [ '6', '7', '\\Uabc\\E', '1', '2', '3', 'def' ],
        '67\Uabc\\E123def with \\d lexer',
    );

    is_deeply( $r->reset->add( '67\\Q(?:a)?\\E123def' )->_path,
        [ '6', '7', '\\Q(?:a)?\\E', '1', '2', '3', 'def' ],
        '67\Uabc\\E123def with \\d lexer',
    );

    $Regexp::Assemble::Default_Lexer = $save;
}

is( Regexp::Assemble->new->debug(1)->add( qw/
        0\.0 0\.2 0\.7 0\.01 0\.003
    / )->as_string(indent => 4),
'0\.
(?:
    0
    (?:
        03
        |1
    )
    ?
    |[27]
)'
, 'pretty 0.0 0.2 0.7 0.01 0.003' );

{
    my $ra = Regexp::Assemble->new->debug(3);

    is( $ra->add( qw/ dog darkness doggerel dark / )->as_string,
        'd(?:ark(?:ness)?|og(?:gerel)?)' );

    is( $ra->add( qw/ limit lit / )->as_string,
        'l(?:im)?it' );

    is( $ra->add( qw/ seafood seahorse sea / )->as_string,
        'sea(?:horse|food)?' );

    is( $ra->add( qw/ bird cat dog elephant fox / )->as_string,
        '(?:(?:elephan|ca)t|bird|dog|fox)' );

    is( $ra->add( qw/ bit bat sit sat fit fat / )->as_string,
        '[bfs][ai]t' );

    is( $ra->add( qw/ split splat slit slat flat flit / )->as_string,
        '(?:sp?|f)l[ai]t' );

    is( $ra->add( qw/bcktx bckx bdix bdktx bdkx/ )
        ->as_string, 'b(?:d(?:kt?|i)|ckt?)x',
        'bcktx bckx bdix bdktx bdkx' );

    is( $ra->add( qw/gait grit wait writ /)->as_string,
        '[gw][ar]it' );

    is( $ra->add( qw/gait grit lit limit /)->as_string,
        '(?:l(?:im)?|g[ar])it' );

    is( $ra->add( qw/bait brit frit gait grit tait wait writ /)->as_string,
        '(?:[bgw][ar]|fr|ta)it' );

    is( $ra->add( qw/schoolkids acids acidoids/ )->as_string,
        '(?:ac(?:ido)?|schoolk)ids' );

    is( $ra->add( qw/schoolkids acidoids/ )->as_string,
        '(?:schoolk|acido)ids' );

    is( $ra->add( qw/nonschoolkids nonacidoids/ )->as_string,
        'non(?:schoolk|acido)ids' );

    is( $ra->add( qw/schoolkids skids acids acidoids/ )->as_string,
        '(?:s(?:chool)?k|ac(?:ido)?)ids' );

    is( $ra->add( qw/kids schoolkids skids acids acidoids/ )->as_string,
        '(?:(?:s(?:chool)?)?k|ac(?:ido)?)ids' );

    is( $ra->add( qw(abcd abd acd ad bcd bd d) )->as_string,
        '(?:(?:ab?|b)c?)?d', 'abcd abd acd ad bcd bd d',
        'indentical nodes in sub_path/insert_node(bifurc)');

    is( $ra->add( qw(^a$ ^ab$ ^abc$ ^abd$ ^bdef$ ^bdf$ ^bef$ ^bf$) )->as_string,
        '^(?:a(?:b[cd]?)?|bd?e?f)$', 'fused node');

    is( $ra->add(qw[bait brit frit gait grit tait wait writ])->as_string,
        '(?:[bgw][ar]|fr|ta)it', 'after _insert_path()');

    is( $ra->add(qw(0 1 10 100))->as_string,
        '(?:1(?:0?0)?|0)', '_scan_node slid' );

    is( $ra->add( qw(abcd abd bcd bd d) )->as_string,
        '(?:a?bc?)?d', 'abcd abd bcd bd d' );
}

{
    my $r = Regexp::Assemble->new->debug(8)->add(qw(this that));
    my $re = $r->re;
    is( $re, '(?-xism:th(?:at|is))', 'time debug' );
}

{
    my $r = Regexp::Assemble->new->add(qw(this that))->debug(8)->add('those');
    my $re = $r->re;
    is( $re, '(?-xism:th(?:ose|at|is))', 'deferred time debug' );
}

{
    my $r = Regexp::Assemble->new->debug(8)->add(qw(this that those));
    # sabotage
    delete $r->{_begin_time};
    is( $r->as_string, 'th(?:ose|at|is)', 'time debug mangle' );

    # use internal time() instead of Time::HiRes
    delete $r->{_time_func};
    $r->{_use_time_hires} = 'more sabotage';
    $r->reset->add(qw(abc ac));
    is( $r->as_string, 'ab?c', 'internal time debug' );
}

is_deeply( Regexp::Assemble->new->debug(4)->_fastlex('ab+c{2,4}'),
    ['a', 'b+', 'c{2,4}'],
    '_fastlex reg plus min-max'
);

my $x;
is_deeply( $x = Regexp::Assemble->new->debug(4)->_fastlex('\\d+\\s{3,4}?\\Qa+\\E\\lL\\uu\\Ufo\\E\\Lba\\x40'),
    ['\\d+', '\\s{3,4}?', 'a', '\\+', qw(l U F O b a @)],
    '_fastlex backslash'
) or diag("@$x");

is_deeply( Regexp::Assemble->new->debug(4)->_fastlex('\\Q\\L\\Ua+\\E\\Ub?\\Ec'),
    [qw(a \\+ B? c)], '_fastlex in and out of quotemeta'
);

is_deeply( $x = Regexp::Assemble->new->debug(4)->_fastlex('\\bw[0-5]*\\\\(?:x|y){,5}?\\'),
    [qw(\\b w [0-5]* \\\\), '(?:x|y){,5}?'], '_fastlex more metachars'
) or diag("@$x");

is_deeply( $x = Regexp::Assemble->new(debug => 4)->_fastlex('\\cG\\007'),
    [qw(\\cG \\cG)], '_fastlex backslash misc'
) or diag("@$x");

is( $_, $fixed, '$_ has not been altered' );
