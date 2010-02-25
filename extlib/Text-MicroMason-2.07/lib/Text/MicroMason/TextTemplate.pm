package Text::MicroMason::TextTemplate;

use Text::MicroMason::PassVariables;
@ISA = 'Text::MicroMason::PassVariables';

use strict;

use Text::Balanced 'extract_multiple', 'extract_codeblock';

######################################################################

my $lexer_rule = [ { TTBlock => sub { extract_codeblock($_[0],'{}','') } } ];

# @tokens = $mason->lex( $template );
sub lex {
  my $self = shift;
  map { ( ! ref) ? ( text => $_ ) : ( expr => substr($$_, 1, -1) ) } 	
				extract_multiple( shift(), $lexer_rule );
}

######################################################################

# Text elements used for subroutine assembly
sub assembler_rules {
  (shift)->NEXT('assembler_rules', @_), 

  init_output => 'my $OUT = ""; my $_out = sub {$OUT .= join "", @_};',
  add_output => '  $OUT .= join "", ',
  return_output => '$OUT;',
}

######################################################################

my $seqno = 0;
sub prepare {
  my $self = shift;
  $self->NEXT('prepare', @_,
	$self->{package} ? () : ( package => __PACKAGE__ . '::GEN' . $seqno++ )
  )
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::TextTemplate - Alternate Syntax like Text::Template


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

  use Text::MicroMason;
  my $mason = Text::MicroMason::Base->new( -TextTemplate );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

Text::Template provides a syntax to mix Perl into a text template:

  { my $hour = (localtime)[2];
    my $daypart = ( $hour > 11 ) ? 'afternoon' : 'morning'; 
  '' }
  Good { $daypart }, { $name }!


=head1 DESCRIPTION

This mixin class overrides several methods to allow MicroMason to emulate
the template syntax and some of the other features of Text::Template.

=head2 Compatibility with Text::Template

This is not a drop-in replacement for Text::Template, as the Perl calling
interface is quite different, but it should be able to process most
existing templates without major changes.

This should allow current Text::Template users to take advantage of
MicroMason's one-time compilation feature, which in theory could be faster than
Text::Template's repeated evals for each expression.  (No benchmarking yet.)

Contributed patches to more closely support the syntax of Text::Template 
documents would be welcomed by the author.

=head2 Template Syntax

The following elements are recognized by the TextTemplate lexer:

=over 4

=item *

I<literal_text>

Anything not specifically parsed by the below rule is interpreted as literal text.

=item *

{ I<perl_expr> }

A Perl expression to be interpolated into the result.

    Good { (localtime)[2]>11 ? 'afternoon' : 'morning' }.

The block may span multiple lines and is scoped inside a "do" block,
so it may contain multiple Perl statements and it need not end with
a semicolon.

    Good { my $h = (localtime)[2]; $h > 11 ? 'afternoon' 
                                           : 'morning'  }.

To make a block silent, use an empty string as the final expression in the block.

    { warn "Interpreting template"; '' }
    Hello there.

Although the blocks are not in the same a lexical scope, you can use local variables defined in one block in another:

    { $phase = (localtime)[2]>11 ? 'afternoon' : 'morning'; '' }
    Good { $phrase }.

=back

=head2 Argument Passing

Like Text::Template, this package clobbers a target namespace to pass in template arguments as package variables. For example, if you pass in an argument list of C<foo =E<gt> 23>, it will set the variable $foo in your package.

The strict pragma is disabled to facilitate these variable references. 

Internally, this module inherits this functionality from the PassVariables mixin. If you are using the TextTemplate mixin, do not also specify the PassVariables mixin or it will be included twice. For more information, see L<Text::MicroMason::PassVariables>.

=head2 Supported Attributes

=over 4

=item package

Target package namespace.

=back

=head2 Private Methods

=over 4

=item prepare()

If a package has not been specified, this method generates a new package namespace to use only for compilation of a single template.

=item lex()

Lexer for matched braces - produces only text and expr tokens. Uses Text::Balanced.

=back


=head1 SEE ALSO

The interface being emulated is described in L<Text::Template>.

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

