#!/usr/bin/perl -w

use strict;
use Test::More tests => 28;

use Text::MicroMason;
my $m = Text::MicroMason->new( );

######################################################################

{
    my $scr_mobj = "Hello <% die('Foo!') %>!";

    is eval { $m->execute( text => $scr_mobj ); 1 }, undef;
    like ($@, qr/Foo!/, "Error $@ must match Foo!");

    is eval { $m->execute( text => $scr_mobj ); 1 }, undef;
    like ($@, qr<\QMicroMason execution failed: Foo! at text template (compiled at t/08-errors.t line>, 
          "Error $@ must match MicroMason failure");

    is eval { $m->execute( file => 'samples/die.msn' ); 1 }, undef;
    like ($@, qr(\QMicroMason execution failed: Foo! at samples/die.msn line),
          "Error $@ must match MicroMason failure");
}

######################################################################

{
    my $scr_mobj = <<EOT;
Hello world!
This <% thing( %> is a test.
End.
EOT

    is eval { $m->compile( text => $scr_mobj ); 1 }, undef, "template with error dies";
    ok my @lines = split(/\n/, $@), 'multiline output in $@';
    like shift @lines, qr{MicroMason compilation failed: syntax error at text template \(compiled at t/08-errors.t line \d+\) line 8},
        'first line of $@ describes the error location'
            or diag $@;
    like shift @lines, qr/^$/, 'second line of $@ is blank'
        or diag $@;

    like $lines[0], qr{   0  # line 1 "text template \(compiled at t/08-errors.t line }, 'third line of $@ has a #line'
        or diag $@;

    like pop @lines, qr{\s+eval \{\.\.\.\} called at t/08-errors.t line \d+}, 'last line of $@ has line number too'
        or diag $@;

    # Perl 5.6 has one line of "at line number" junk, but perl 5.8 has
    # two lines. The next line is our diagnostics message.
    ok ((pop @lines) =~ m{\Q** Please use Text::MicroMason->new(-LineNumbers) for better diagnostics!}
        or (pop @lines) =~ m{\Q** Please use Text::MicroMason->new(-LineNumbers) for better diagnostics!});

    my $n = 0;
    foreach my $line (@lines) {
        like $line, qr/^\s*$n\s+/ or diag $@;
        $n++;
    }
}
