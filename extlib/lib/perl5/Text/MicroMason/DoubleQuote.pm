package Text::MicroMason::DoubleQuote;

use strict;

######################################################################

# ( $type, $value ) = $mason->lex_token();
sub lex_token {
  / (.*) /xcogs ? ( expr => do { my $x = $1; $x =~ s/\|/\\|/g; "qq|$x|" } ) : ()
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::DoubleQuote - Minimalist Interpolation Engine


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason::Base->new( -DoubleQuote );

Templates can be written using Perl's double-quote interpolation syntax:

    $coderef = $mason->compile( text => 'Hello $ARGS{name}!' );
    print $coderef->( name => 'World' );


=head1 DESCRIPTION

Text::MicroMason::DoubleQuote uses Perl's double-quoting interpolation as a minimalist syntax for templating.

Of course you don't need this module for simple cases of interpolation, but if you're already using the MicroMason framework to process template files from disk, this module should allow you to make your simplest templates run even faster.

To embed values other than simple scalars in a double-quoted expression you can use the ${ expr } syntax. For example, you can interpolate a function call with C<"${ \( time() ) }"> or C<"@{[mysub(1,2,3)]}">. As noted in L<perldaq4>, "this is fraught with quoting and readability problems, but it is possible." In particular, this can quickly become a mess once you start adding loops or conditionals. If you do find yourself making use of this feature, please consider switching to one of the more powerful template syntaxes like L<Text::MicroMason::HTMLMason>.


=head1 SEE ALSO

To refer to arguments as $name rather than as $ARGS{name}, see L<Text::MicroMason::PassVariables>.

For an overview of this distribution, see L<Text::MicroMason>.

This is a subclass intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
