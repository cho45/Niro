#!/usr/bin/perl -w

use lib qw(t/lib);

use Test::More tests => 30;

BEGIN { use_ok('Exporter::Lite'); }
can_ok(__PACKAGE__, 'import');

{
    package Test1;
    use Dummy;

    ::can_ok('Dummy', 'import');
    ::ok( defined &foo,     '@EXPORT' );
    ::is( foo, 42,          '    in one piece' );
    ::is( $foo, 'foofer',   '    and variables' );
}

{
    package YATest1;
    use Dummy qw(foo);

    ::ok( defined &foo,     '@EXPORT with explicit request' );
    ::is( foo, 42,          '    in one piece' );
}

{
    package Test2;
    use Dummy ();

    ::ok( !defined &foo,    'import with ()' );
}

{
    package Test3;
    eval { Dummy->import('car') };
    ::like( $@, '/"car" is not exported by the Dummy module/',
                'importing non-expoted function' );
}


{
    package Test4;
    use Dummy qw(bar);
    ::ok( defined &bar,     '@EXPORT_OK' );
    ::ok( !defined &foo,    '    overrides @EXPORT' );
    ::ok( !defined &my_sum, '    only what we asked for from @EXPORT_OK' );
    ::is( bar, 23,          '    not damaged in transport' );
}

{
    package YATest4;
    use Dummy qw(bar $bar);
    ::ok( defined &bar,     '@EXPORT_OK' );
    ::ok( !defined &foo,    '    overrides @EXPORT' );
    ::ok( !defined &my_sum, '    only what we asked for from @EXPORT_OK' );
    ::is( bar, 23,          '    not damaged in transport' );
    ::is( $bar, 'barfer',   '    $bar exported' );
}

{
    package Test5;

    my $warning = '';
    local $SIG{__WARN__} = sub { $warning = join '', @_ };
    eval 'use Dummy qw(bar)';
    eval 'use Dummy qw(&bar)';
    ::ok( defined &bar,     'importing multiple times' );
    ::is( $@, '',           '   no errors' );
    ::is( $warning, '',     '   no warnings' );
}

{
    package Test6;
    
    my $warning = '';
    local $SIG{__WARN__} = sub { $warning = join '', @_ };
    eval 'use Dummy qw(bar &bar bar bar &bar bar)';
    ::ok( defined &bar,     'importing duplicates' );
    ::is( $@, '',           '   no errors' );
    ::is( $warning, '',     '   no warnings' );
}

{
    package Test7;
    use Dummy qw(my_sum bar foo);

    ::is( prototype("Dummy::my_sum"), '&@', 'imported sub has prototype' );
    ::is( prototype("my_sum"),        '&@', '   prototype preserved' );

    my @list =  qw(1 2 3 4);
    my $sum = my_sum { $_[0] + $_[1] } @list;
    ::is( $sum, 10, '    and it works' );
}


{
    package Test8;
    eval "use Dummy 0.5";
    ::is( $@, '',         'use Foo VERSION' );

    eval "use Dummy 99";
    ::like( $@, '/Dummy version 99.* required/',
            'use with version check' );
}
