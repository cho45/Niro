use strict;
use warnings;

use Devel::StackTrace;
use Test::More;

BEGIN
{
    my $tests = 40;
    eval { require Exception::Class };
    $tests++ if ! $@ && $Exception::Class::VERSION >= 1.09;

    plan tests => $tests;
}

sub get_file_name { File::Spec->canonpath( (caller(0))[1] ) }
my $test_file_name = get_file_name();

# Test all accessors
{
    my $trace = foo();

    my @f = ();
    while ( my $f = $trace->prev_frame ) { push @f, $f; }

    my $cnt = scalar @f;
    is( $cnt, 4,
        "Trace should have 4 frames" );

    @f = ();
    while ( my $f = $trace->next_frame ) { push @f, $f; }

    $cnt = scalar @f;
    is( $cnt, 4,
        "Trace should have 4 frames" );

    is( $f[0]->package, 'main',
        "First frame package should be main" );

    is( $f[0]->filename, $test_file_name, "First frame filename should be $test_file_name" );

    is( $f[0]->line, 1012, "First frame line should be 1012" );

    is( $f[0]->subroutine, 'Devel::StackTrace::new',
        "First frame subroutine should be Devel::StackTrace::new" );

    is( $f[0]->hasargs, 1, "First frame hasargs should be true" );

    ok( ! $f[0]->wantarray,
        "First frame wantarray should be false" );

    my $trace_text = <<"EOF";
Trace begun at $test_file_name line 1012
main::baz(1, 2) called at $test_file_name line 1007
main::bar(1) called at $test_file_name line 1002
main::foo at $test_file_name line 21
EOF

    is( $trace->as_string, $trace_text, 'trace text' );
}

# Test constructor params
{
    my $trace = SubTest::foo( ignore_class => 'Test' );

    my @f = ();
    while ( my $f = $trace->prev_frame ) { push @f, $f; }

    my $cnt = scalar @f;

    is( $cnt, 1, "Trace should have 1 frame" );

    is( $f[0]->package, 'main',
        "The package for this frame should be main" );

    $trace = Test::foo( ignore_class => 'Test' );

    @f = ();
    while ( my $f = $trace->prev_frame ) { push @f, $f; }

    $cnt = scalar @f;

    is( $cnt, 1, "Trace should have 1 frame" );
    is( $f[0]->package, 'main',
        "The package for this frame should be main" );
}

# 15 - stringification overloading
{
    my $trace = baz();

    my $trace_text = <<"EOF";
Trace begun at $test_file_name line 1012
main::baz at $test_file_name line 90
EOF

    my $t = "$trace";
    is( $t, $trace_text, 'trace text' );
}

# 16-18 - frame_count, frame, reset_pointer, frames methods
{
    my $trace = foo();

    is( $trace->frame_count, 4,
        "Trace should have 4 frames" );

    my $f = $trace->frame(2);

    is( $f->subroutine, 'main::bar',
        "Frame 2's subroutine should be 'main::bar'" );

    $trace->next_frame; $trace->next_frame;
    $trace->reset_pointer;

    $f = $trace->next_frame;
    is( $f->subroutine, 'Devel::StackTrace::new',
        "next_frame should return first frame after call to reset_pointer" );

    my @f = $trace->frames;
    is( scalar @f, 4,
        "frames method should return four frames" );

    is( $f[0]->subroutine, 'Devel::StackTrace::new',
        "first frame's subroutine should be Devel::StackTrace::new" );

    is( $f[3]->subroutine, 'main::foo',
        "last frame's subroutine should be main::foo" );
}

# Storing references
{
    my $obj = RefTest->new;

    my $trace = $obj->{trace};

    my $call_to_trace = ($trace->frames)[1];

    my @args = $call_to_trace->args;

    is( scalar @args, 1,
        "Only one argument should have been passed in the call to trace()" );

    isa_ok( $args[0], 'RefTest' );
}

# Not storing references
{
    my $obj = RefTest2->new;

    my $trace = $obj->{trace};

    my $call_to_trace = ($trace->frames)[1];

    my @args = $call_to_trace->args;

    is( scalar @args, 1,
        "Only one argument should have been passed in the call to trace()" );

    like( $args[0], qr/RefTest2=HASH/,
        "Actual object should be replaced by string 'RefTest2=HASH'" );
}

# Not storing references (deprecated interface)
{
    my $obj = RefTest3->new;

    my $trace = $obj->{trace};

    my $call_to_trace = ($trace->frames)[1];

    my @args = $call_to_trace->args;

    is( scalar @args, 1,
        "Only one argument should have been passed in the call to trace()" );

    like( $args[0], qr/RefTest3=HASH/,
        "Actual object should be replaced by string 'RefTest3=HASH'" );
}

# No ref to Exception::Class::Base object without refs
if ( $Exception::Class::VERSION && $Exception::Class::VERSION >= 1.09 )
{
    eval { Exception::Class::Base->throw( error => 'error',
                                          show_trace => 1,
                                        ) };
    my $exc = $@;
    eval { quux($exc) };

    ok( ! $@, 'create stacktrace with no refs and exception object on stack' );
}

{
    sub FooBar::some_sub { return Devel::StackTrace->new }

    my $trace = eval { FooBar::some_sub('args') };

    my $f = ($trace->frames)[2];

    is( $f->subroutine, '(eval)', 'subroutine is (eval)' );

    my @args = $f->args;

    is( scalar @args, 0, 'no args given to eval block' );
}

{
    {
        package FooBarBaz;

        sub func2 { return Devel::StackTrace->new( ignore_package => qr/^FooBar/ ) }
        sub func1 { FooBarBaz::func2() }
    }

    my $trace = FooBarBaz::func1('args');

    my @f = $trace->frames;

    is( scalar @f, 1, 'check regex as ignore_package arg' );
}

{
    package StringOverloaded;

    use overload '""' => sub { 'overloaded' };
}

{
    my $o = bless {}, 'StringOverloaded';

    my $trace = baz($o);

    unlike( $trace->as_string, qr/\boverloaded\b/, 'overloading is ignored by default' );
}

{
    my $o = bless {}, 'StringOverloaded';

    my $trace = respect_overloading($o);

    like( $trace->as_string, qr/\boverloaded\b/, 'overloading is ignored by default' );
}

{
    package BlowOnCan;

    sub can { die 'foo' }
}

{
    my $o = bless {}, 'BlowOnCan';

    my $trace = baz($o);

    like( $trace->as_string, qr/BlowOnCan/, 'death in overload::Overloaded is ignored' );
}


{
    my $trace = max_arg_length('abcdefghijklmnop');

    my $trace_text = <<"EOF";
Trace begun at $test_file_name line 1027
main::max_arg_length('abcdefghij...') called at $test_file_name line 260
EOF

    is( $trace->as_string, $trace_text, 'trace text' );
}

SKIP:
{
    skip "Test only runs on Linux", 1
        unless $^O eq 'linux';

    my $frame = Devel::StackTraceFrame->new( [ 'Foo', 'foo/bar///baz.pm', 10, 'bar', 1, 1, '', 0 ],
                                             [] );

    is( $frame->filename, 'foo/bar/baz.pm', 'filename is canonicalized' );
}

{
    my $obj = RefTest4->new();

    my $trace = $obj->{trace};

    ok( ( ! grep { ref $_ } map { @{ $_->{args} } } @{ $trace->{raw} } ),
        'raw data does not contain any references when no_refs is true' );

    is( $trace->{raw}[1]{args}[1], 'not a ref',
        'non-refs are preserved properly in raw data as well' );
}

{
    my $trace = overload_no_stringify( CodeOverload->new() );

    eval { $trace->as_string() };

    is( $@, q{},
        'no error when respect_overload is true and object overloads but does not stringify' );
}

{
    my $trace = Filter::foo();

    my @frames = $trace->frames();
    is( scalar @frames, 2, 'filtered trace has just 2 frames' );
    is( $frames[0]->subroutine(), 'Devel::StackTrace::new', 'first subroutine' );
    is( $frames[1]->subroutine(), 'Filter::bar', 'second subroutine (skipped Filter::foo)' );
}

# This means I can move these lines down without constantly fiddling
# with the checks for line numbers in the tests.

#line 1000
sub foo
{
    bar(@_, 1);
}

sub bar
{
    baz(@_, 2);
}

sub baz
{
    Devel::StackTrace->new( @_ ? @_[0,1] : () );
}

sub quux
{
    Devel::StackTrace->new( no_refs => 1 );
}

sub respect_overloading
{
    Devel::StackTrace->new( respect_overload => 1 );
}

sub max_arg_length
{
    Devel::StackTrace->new( max_arg_length => 10 );
}

sub overload_no_stringify
{
    return Devel::StackTrace->new( no_refs => 1, respect_overload => 1 );
}


package Test;

sub foo
{
    trace(@_);
}

sub trace
{
    Devel::StackTrace->new(@_);
}

package SubTest;

use base qw(Test);

sub foo
{
    trace(@_);
}

sub trace
{
    Devel::StackTrace->new(@_);
}

package RefTest;

sub new
{
    my $self = bless {}, shift;

    $self->{trace} = trace($self);

    return $self;
}

sub trace
{
    Devel::StackTrace->new();
}

package RefTest2;

sub new
{
    my $self = bless {}, shift;

    $self->{trace} = trace($self);

    return $self;
}

sub trace
{
    Devel::StackTrace->new( no_refs => 1 );
}

package RefTest3;

sub new
{
    my $self = bless {}, shift;

    $self->{trace} = trace($self);

    return $self;
}

sub trace
{
    Devel::StackTrace->new( no_object_refs => 1 );
}

package RefTest4;

sub new
{
    my $self = bless {}, shift;

    $self->{trace} = trace( $self, 'not a ref' );

    return $self;
}

sub trace
{
    Devel::StackTrace->new( no_refs => 1 );
}

package CodeOverload;

use overload '&{}' => sub { 'foo' };

sub new
{
    my $class = shift;
    return bless {}, $class;
}

package Filter;

sub foo
{
    bar();
}

sub bar
{
    return Devel::StackTrace->new( frame_filter => sub { $_[0]{caller}[3] ne 'Filter::foo' } );
}
