package Text::MicroMason::Embperl;

use strict;
use Carp;

use Safe;

######################################################################

my %block_types = ( 
  '-'  => 'perl',	# [- perl statements -]
  '+'  => 'expr',	# [+ perl expression +]
  '!'  => 'once',	# [! perl statements !]
  '$'  => 'ep_meta',	# [$ command args $]
);

sub lex_token {
  # Blocks in [-/+/! ... -/+/!] tags.
  /\G \[ (\-|\+|\!) \s* (.*?) \s* \1 \] /gcxs ? ( $block_types{$1} => $2 ) :
  
  # Blocks in [$ command ... $] tags.
  /\G \[ \$ \s* (\S+)\s*(.*?) \s* \$ \] /gcxs ? ( "ep_$1" => $2 ) :
  
  # Things that don't match the above
  /\G ( (?: [^\[] | \[(?![\-\+\!\$]) )+ ) /gcxs ? ( 'text' => $1 ) : 

  ()
}

######################################################################

sub assembler_rules {
  my $self = shift;
  $self->NEXT('assembler_rules', @_), 
    ep_if_token => "perl if ( TOKEN ) {",
    ep_elsif_token => "perl } elsif ( TOKEN ) {",
    ep_else_token => "perl } else {",
    ep_endif_token => "perl }",
    ep_while_token => "perl while ( TOKEN ) {",
    ep_endwhile_token => "perl }",
    ep_foreach_token => "perl foreach TOKEN {",
    ep_endforeach_token => "perl }",
    ep_do_token => "perl do {",
    ep_until_token => "perl } until ( TOKEN );",
    ep_var_token => "perl use strict; use vars qw( TOKEN );",
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::Embperl - Alternate Syntax like Embperl Templates


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason::Base->new( -Embperl );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

Embperl syntax provides several ways to mix Perl into a text template:

    [- my $name = $ARGS{name}; -]
    [$ if $name eq 'Dave' $]
      I'm sorry [+ $name +], I'm afraid I can't do that right now.
    [$ else $]
      [- 
	my $hour = (localtime)[2];
	my $daypart = ( $hour > 11 ) ? 'afternoon' : 'morning'; 
      -]
      Good [+ $daypart +], [+ $name +]!
    [$ endif $]


=head1 DESCRIPTION

This subclass replaces MicroMason's normal lexer with one that supports a syntax similar to Embperl.

=head2 Compatibility with Embperl

Embperl is a full-featured application server toolkit with many fatures, of which only the templating functionality is emulated.

This is not a drop-in replacement for Embperl, as the implementation is quite different, but it should be able to process some existing templates without major changes.

The following features of EmbPerl syntax are supported:

=over 4

=item *

Square-bracket markup tags

=back

The following syntax features of are B<not> supported:

=over 4

=item *

Dynamic HTML tags

=back

=head2 Template Syntax

The following elements are recognized by the Embperl lexer:

=over 4

=item *

[- perl statements -]

Arbitrary Perl code to be executed at this point in the template.

=item *

[+ perl expression +]

A Perl expression to be evaluated and included in the output.

=item *

[! perl statements !]

Arbitrary Perl code to be executed once when the template is compiled.

=item *

[$ I<name> ... $]

Supported command names are: if, elsif, else, endif, foreach, endforeach, while, endwhile, do, until, var.

=back

=head2 Private Methods

=over 4

=item lex_token

  ( $type, $value ) = $mason->lex_token();

Lexer for [. ... .] tags.

Attempts to parse a token from the template text stored in the global $_ and returns a token type and value. Returns an empty list if unable to parse further due to an error.

=item assembler_rules()

Adds mappings from command names used in [$ ... $] tokens to the equivalent 
Perl syntax.

  %syntax_rules = $mason->assembler_rules();

=back

=cut


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
