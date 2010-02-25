package Text::MicroMason::PLP;

use strict;
use Carp;

use Safe;

######################################################################

sub lex_token {
  # Blocks in <: ... :> tags.
  /\G \< \: (\=)? ( .*? ) \: \> /gcxs ? ( ($1 ? 'expr' : 'perl') => $2 ) :
  
  # Blocks in <( ... )> tags.
  /\G \< \( ( .*? ) \) \> /gcxs ? ( 'include' => $1 ) :
  
  # Things that don't match the above
  /\G ( (?: [^\<]+ | \<(?![\:\(]) )? ) /gcxs ? ( 'text' => $1 ) :

  # Lexer error
  ()
}

# $perl_code = $mason->assemble( @tokens );
sub assemble {
  my $self = shift;
  my @tokens = @_;
  
  for ( my $position = 0; $position <= int( $#tokens / 2 ); $position ++ ) {
    if ( $tokens[$position * 2] eq 'include' ) {
      my $token = $tokens[$position * 2 + 1];
      splice @tokens, $position * 2, 2, $self->lex( $self->read_file( $token ) )
    }
  }
  
  $self->NEXT('assemble', @tokens );
}

######################################################################

package Text::MicroMason::Commands;

# Trick PAUSE into indexing us properly: this package used to be in
# MicroMason.pm, so it gained version 1.07 on PAUSE, and the new ones
# won't be reindexed unless they have a greater version.
our $VERSION = "1.9";

use vars qw( $m );
sub include {
  $m->execute( file => @_ )
}

sub Include {
  $m->execute( file => @_ )
}

sub ReadFile {
  $m->read_file( @_ )
}

sub Entity {
  eval { require HTML::Entities; no strict; *Entity = \&HTML::Entities::encode }
	?  goto &HTML::Entities::encode : die "Can't load HTML::Entities";
	
}

sub EncodeURI {
  eval { require URI::Escape; no strict; *Entity = \&URI::Escape::uri_escape }
	?  goto &URI::Escape::uri_escape : die "Can't load HTML::Entities";
}


######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::PLP - Alternate Syntax like PLP Templates


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason::Base->new( -PLP );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

The PLP syntax provides another way to mix Perl into a text template:

    <: my $name = $ARGS{name};
      if ( $name eq 'Dave' ) {  :>
      I'm sorry <:= $name :>, I'm afraid I can't do that right now.
    <: } else { 
	my $hour = (localtime)[2];
	my $daypart = ( $hour > 11 ) ? 'afternoon' : 'morning'; 
      :>
      Good <:= $daypart :>, <:= $name :>!
    <: } :>


=head1 DESCRIPTION

This subclass replaces MicroMason's normal lexer with one that supports a syntax similar to that provided by the PLP module.

=head2 Compatibility with PLP

PLP is a web-oriented system with many fatures, of which only the templating functionality is emulated.

This is not a drop-in replacement for PLP, as the implementation is quite different, but it should be able to process some existing templates without major changes.

The following features of EmbPerl syntax are supported:

=over 4

=item *

Basic markup tags

=back

The following syntax features of are B<not> supported:

=over 4

=item *

Emulation of functions defined in PLP::Functions is incomplete.

=item *

Web server interface with tied 

=back

=head2 Template Syntax

The following elements are recognized by the PLP lexer:

=over 4

=item *

E<lt>: perl statements :E<gt>

Arbitrary Perl code to be executed at this point in the template.

=item *

E<lt>:= perl expression :E<gt>

A Perl expression to be evaluated and included in the output.

=item *

E<lt>( file, arguments )E<gt>

Includes an external template file. 

=back

=head2 Private Methods

=over 4

=item lex_token

  ( $type, $value ) = $mason->lex_token();

Lexer for <: ... :> and <( ... )> tags.

Attempts to parse a token from the template text stored in the global $_ and returns a token type and value. Returns an empty list if unable to parse further due to an error.

=item assemble

Performs compile-time file includes for any include tokens found by lex_token. 

=back

=cut


=head1 SEE ALSO

The interface being emulated is described in L<PLP>.

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
