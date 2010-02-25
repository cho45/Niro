# 04_match.t
#
# Test suite for Regexp::Assemble
# Tests to see than an assembled regexp matches all that it is supposed to
#
# copyright (C) 2004-2006 David Landgren

use strict;
eval qq{
    use Test::More tests => 1381;
};
if( $@ ) {
    warn "# Test::More not available, no tests performed\n";
    print "1..1\nok 1\n";
    exit 0;
}

use Regexp::Assemble;

my $fixed = 'The scalar remains the same';
$_ = $fixed;

# Bug #17507 as noted by barbie
#
# There appears to be a problem with the substitute key on Windows, for
# at least Perl 5.6.1, which causes this test script to terminate
# immediately on encountering the character.
my $subchr    = 0x1a;
my $win32_56x = ($^O eq 'MSWin32' && $] < 5.008) ? 1 : 0;
diag("enabling defensive workaround for $] on $^O") if $win32_56x;

{
    for my $outer ( 0 .. 15 ) {
        my $re = Regexp::Assemble->new->anchor_string->chomp(0);
        for my $inner ( 0 .. 15 ) {
            next if $win32_56x and $subchr == ($outer*16 + $inner);
            $re->add( quotemeta( chr( $outer*16 + $inner )));
        }
        for my $inner ( 0 .. 15 ) {
            if( $win32_56x and $subchr == ($outer*16 + $inner)) {
                 ok( 1, "faking $subchr for 5.6 on Win32" );
            }
            else {
                my $ch = chr($outer*16 + $inner);
                like( $ch, qr/$re/, "run $ch ($outer:$inner) $re" );
            }
        }
    }
}

for( 0 .. 255 ) {
    if( $win32_56x and $subchr == $_) {
        pass("Fake a single for 5.6 on Win32");
        next;
    }
    my $ch = chr($_);
    my $qm = Regexp::Assemble->new(chomp=>0)->anchor_string->add(quotemeta($ch));
    like( $ch, qr/$qm/, "quotemeta(chr($_))" );
}

for( 0 .. 127 ) {
    if( $win32_56x and $subchr == $_) {
        pass( "Fake a hi for 5.6 on Win32");
        pass( "Fake a lo for 5.6 on Win32");
        next;
    }
    my $lo = chr($_);
    my $hi = chr($_+128);
    my $qm = Regexp::Assemble->new(chomp => 0, anchor_string => 1)->add(
        quotemeta($lo),
        quotemeta($hi),
    );
    like( $lo, qr/$qm/, "$_: quotemeta($lo) lo" );
    like( $hi, qr/$qm/, "$_: quotemeta($hi) hi" );
}

sub match {
    my $re   = Regexp::Assemble->new;
    my $rela = Regexp::Assemble->new->lookahead(1);
    my $tag = shift;
    $re->add(@_);
    $rela->add(@_);
    my $reind = $re->clone;
    $reind = $re->clone->flags('x')->re(indent => 3);
    my $rered = $re->clone->reduce(0);
    my $str;
    for $str (@_) {
        like( $str, qr/^$re$/,     "-- $tag: $str" ) or diag( " fail $str\n# match by $re\n" );
        like( $str, qr/^$rela$/,   "LA $tag: $str" ) or diag( " fail $str\n# match by lookahead $rela\n" );
        like( $str, qr/^$reind$/x, "IN $tag: $str" ) or diag( " fail $str\n# match by indented $reind\n" );
        like( $str, qr/^$rered$/,  "RD $tag: $str" ) or diag( " fail $str\n# match by non-reduced $rered\n" );
    }
}

sub match_list {
    my $tag  = shift;
    my $patt = shift;
    my $test = shift;
    my $re   = Regexp::Assemble->new->add(@$patt);
    my $rela = Regexp::Assemble->new->lookahead(1)->add(@$patt);
    my $str;
    for $str (@$test) {
        ok( $str =~ /^$re$/, "re $tag: $str" ) or diag( "fail re $str\n# in $re\n" );
        ok( $str =~ /^$rela$/, "rela $tag: $str" ) or diag( "fail rela $str\n# in $rela\n" );
    }
}

{
    my $re = Regexp::Assemble->new( flags => 'i' )
        ->add( '^fg' )
        ->re;
    like( 'fgx', qr/$re/, 'fgx/i' );
    like( 'Fgx', qr/$re/, 'Fgx/i' );
    like( 'FGx', qr/$re/, 'FGx/i' );
    like( 'fGx', qr/$re/, 'fGx/i' );
    unlike( 'F', qr/$re/, 'F/i' );
}

{
    my $re = Regexp::Assemble->new( flags => 'x' )
        ->add( '^fish' )
        ->add( '^flash' )
        ->add( '^fetish' )
        ->add( '^foolish' )
        ->re( indent => 2 );
    like( 'fish', qr/$re/, 'fish/x' );
    like( 'flash', qr/$re/, 'flash/x' );
    like( 'fetish', qr/$re/, 'fetish/x' );
    like( 'foolish', qr/$re/, 'foolish/x' );
    unlike( 'fetch', qr/$re/, 'fetch/x' );
}

match_list( 'lookahead car.*',
    [qw[caret caress careful careless caring carion carry carried]],
    [qw[caret caress careful careless caring carion carry carried]],
);

match_list( 'a.x', [qw[ abx adx a.x ]] , [qw[ aax abx acx azx a4x a%x a+x a?x ]] );

match_list( 'POSIX', [qw[ X[0[:alpha:]%] Y[1-4[:punct:]a-c] ]] , [qw(X0 X% Xa Xf Y1 Y; Y! yc)] );

match_list( 'c.z', [qw[ c^z c-z c5z cmz ]] , [qw[ c^z c-z c5z cmz ]] );

match_list( '\d, \D', [ 'b\\d', 'b\\D' ] , [qw[ b4 bX b% b. b? ]] );

match_list( 'abcd',
    [qw[ abc abcd ac acd b bc bcd bd]],
    [qw[ abc abcd ac acd b bc bcd bd]],
);

match( 'foo', qw[ foo bar rat quux ]);

match( '.[ar]it 1', qw[ bait brit frit gait grit tait wait writ ]);

match( '.[ar]it 2', qw[ bait brit gait grit ]);

match( '.[ar]it 3', qw[ bit bait brit gait grit ]);

match( '.[ar]it 4', qw[ barit bait brit gait grit ]);

match( 't.*ough', qw[ tough though trough through thorough ]);

match( 'g.*it', qw[ gait git grapefruit grassquit grit guitguit ]);

match( 'show.*ess', qw[ showeriness showerless showiness showless ]);

match( 'd*', qw[ den-at dot-at den-pt dot-pt dx ]);

match( 'd*', qw[ den-at dot-at den-pt dot-pt d-at d-pt dx ]);

match( 'un*ed', qw[ unimped unimpeded unimpelled ]);

match( '(un)?*(ing)?ing', qw[
    sing swing sting sling
    singing swinging stinging slinging
    unsing unswing unsting unsling
    unsinging unswinging unstinging unslinging
]);

match( 's.*at 1', qw[ sat sweat sailbat ]);

match( 'm[eant]+', qw[ ma mae man mana manatee mane manent manna mannan mant
    manta mat mate matta matte me mean meant meat meet meeten men met meta
    metate mete ]);

match( 'ti[aeinost]+', qw[ tiao tie tien tin tine tinea tinean tineine
    tininess tinnet tinniness tinosa tinstone tint tinta tintie tintiness
    tintist tisane tit titanate titania titanite titano tite titi titian
    titien tittie ]);

is( $_, $fixed, '$_ has not been altered' );
