package Text::MicroMason::Sprintf;

use strict;

######################################################################

# ( $type, $value ) = $mason->lex_token();
sub lex_token {
  / (.*) /xcogs ? ( expr => do { my $x = $1; $x =~ s/\|/\\|/g; "sprintf(qq|$x|, \@_)" } ) : ()
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::Sprintf - Formatted Interpolation Engine


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason::Base->new( -Sprintf );

Templates can be written using Perl's sprintf interpolation syntax:

    $coderef = $mason->compile( text => 'Hello %s' );
    print $coderef->( 'World' );


=head1 DESCRIPTION

Text::MicroMason::Sprintf uses Perl's sprintf formatting syntax for templating.

Of course you don't need this module for simple cases of interpolation, but if you're already using the MicroMason framework to process template files from disk, this module should allow you to make your simplest templates run even faster.

Perl's sprintf function supports traditional Unix-style sprintf() formatting as well as a number of very useful extensions. Consult L<perlfuc/sprintf> for more details. 


=head1 SEE ALSO

For an overview of this distribution, see L<Text::MicroMason>.

This is a subclass intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
