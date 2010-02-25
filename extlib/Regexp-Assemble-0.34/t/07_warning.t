# 07_warning.t
#
# test suite for Regexp::Assemble
# Make sure warnings are emitted when asked for
#
# copyright (C) 2005-2006 David Landgren

use constant WARN_TESTS => 6;

eval qq{use Test::More tests => WARN_TESTS};
if( $@ ) {
    warn "# Test::More not available, no tests performed\n";
    print "1..1\nok 1\n";
    exit 0;
}

my $have_Test_Warn;
BEGIN {
    $have_Test_Warn = do {
        eval "use Test::Warn";
        $@ ? 0 : 1;
    };
}

use Regexp::Assemble;

SKIP: {
    skip( 'Test::Warn not installed on this system', WARN_TESTS )
        unless $have_Test_Warn;

     my $ra = Regexp::Assemble->new( dup_warn => 1 )
         ->add( qw( abc def ghi ));

     my $rax = Regexp::Assemble->new( dup_warn => 0 )
         ->add( qw( abc def ghi ));

     my $ram = Regexp::Assemble->new->dup_warn
         ->add( qw( abc def ghi ));

    warning_is { $rax->add( 'def' ) } { carped => "" }, "do not carp explicit";

    SKIP: {
        skip( "Sub::Uplevel version $Sub::Uplevel::VERSION broken on 5.8.8, 0.13 or better required", 2 )
            if $] == 5.008008 and $Sub::Uplevel::VERSION < 0.13;

        warning_like { $ra->add('def') } qr(duplicate pattern added: /def/ at \S+ line \d+\s*),
            "carp duplicate pattern, warn from new";

        warning_like { $ram->add('abc') } qr(duplicate pattern added: /abc/ at \S+ line \d+\s*),
            "carp duplicate pattern, warn from method";
    }

    $ra->dup_warn(0);
    warning_is { $ra->add( 'ghi' ) } { carped => "" }, "do not carp";
    $ra->dup_warn(1);

    my $dup_count = 0;
    $ra->dup_warn( sub { ++$dup_count } );
    $ra->add( 'abc' );
    cmp_ok( $dup_count, 'eq', 1, 'dup callback' );

    $ra->dup_warn(
        sub {
            warn join('-', @{$_[-1]})
        }
    );
    $ra->add( 'dup' );
    warning_is { $ra->add( 'dup' ) } 'd-u-p',
        "custom carp duplicate pattern";

} # SKIP
