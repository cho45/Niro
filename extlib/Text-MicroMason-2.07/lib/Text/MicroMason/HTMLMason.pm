package Text::MicroMason::HTMLMason;

use strict;

######################################################################

my $re_eol = "(?:\\r\\n|\\r|\\n|\\z)";
my $re_sol = "(?:\\A|(?<=\\r|\\n) )";
my $re_tag = "perl|args|once|init|cleanup|doc|text|expr|file";

# ( $type, $value ) = $mason->lex_token();
sub lex_token {
  # Blocks in <%word> ... <%word> tags.
  /\G \<\%($re_tag)\> (.*?) \<\/\%\1\> $re_eol? /xcogs ? ( $1 => $2 ) :
  
  # Blocks in <% ... %> tags.
  /\G \<\% ( .*? ) \%\> /xcogs ? ( 'expr' => $1 ) :
  
  # Blocks in <& ... &> tags.
  /\G \<\& ( .*? ) \&\> /xcogs ? ( 'file' => $1 ) :
  
  # Lines begining with %
  /\G $re_sol \% ( [^\n\r]* ) $re_eol /xcogs ? ( 'perl' => $1 ) :
  
  # Things that don't match the above
  /\G ( (?: [^\<\r\n%]+ | \<(?!\%|\&) | (?<=[^\r\n\<])% |
	$re_eol (?:\z|[^\r\n\%\<]|(?=\r\n|\r|\n|\%)|\<[^\%\&]|(?=\<[\%\&])) 
	)+ (?: $re_eol +(?:\z|(?=\%|\<\[\%\&])) )?
  ) /xcogs ? ( 'text' => $1 ) : 

  # Lexer error
  ()
}

######################################################################

# Text elements used for subroutine assembly
sub assembler_rules {
  my $self = shift;
  $self->NEXT('assembler_rules'), 
    template => [ qw( @once $sub_start $init_errs $init_output $init_args
		    @init @perl !@cleanup $return_output $sub_end -@doc ) ]
}

sub assemble_args {
  my ( $self, $token ) = @_;
    $token =~ s/^\s*([\$\@\%])(\w+) (?:\s* => \s* ([^\r\n]+))?/
      my $argvar = ($1 eq '$') ? "\$ARGS{$2}" : "$1\{ \$ARGS{$2} }";
      "my $1$2 = exists \$ARGS{$2} ? $argvar : " . 
	    ( defined($3) ? "($argvar = $3)" : 
	      qq{Carp::croak("no value sent for required parameter '$2'")} ) .
      ";"/gexm;
  return ( 'init' => '($#_ % 2) or Carp::croak("Odd number of parameters passed to sub expecting name/value pairs"); ' . "\n" . $token );
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::HTMLMason - Simple Compiler for Mason-style Templating 


=head1 SYNOPSIS

Create a MicroMason object to interpret the templates:

  use Text::MicroMason;
  my $mason = Text::MicroMason->new();

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

Mason syntax provides several ways to mix Perl into a text template:

  <%args>
    $name
  </%args>

  % if ( $name eq 'Dave' ) {
    I'm sorry <% $name %>, I'm afraid I can't do that right now.
  % } else {
    <%perl>
      my $hour = (localtime)[2];
      my $daypart = ( $hour > 11 ) ? 'afternoon' : 'morning'; 
    </%perl>
    Good <% $daypart %>, <% $name %>!
  % }

  <& "includes/standard_footer.msn" &>

  <%doc>
    Here's a private developr comment describing this template. 
  </%doc>


=head1 DESCRIPTION

The Text::MicroMason::HTMLMason class provides lexer and assembler methods that allow Text::MicroMason to handle most elements of HTML::Mason's template syntax.


=head2 Compatibility with HTML::Mason

HTML::Mason is a full-featured application server toolkit with many fatures, of which only the templating functionality is emulated.

The following sets of HTML::Mason features B<are> supported by Text::MicroMason:

=over 4

=item *

Template interpolation with <% expr %> 

=item *

Literal Perl lines with leading % 

=item *

Named %args, %perl, %once, %init, %cleanup, and %doc blocks

=item *

The $m mason object, although with many fewer methods

=item *

Expression filtering with |h and |u (via -Filter mixin)

=back

The following sets of HTML::Mason features are B<not> supported by Text::MicroMason:

=over 4

=item *

No %attr, %flag, %shared, %method, or %def blocks.

=item *

No shared files like autohandler and dhandler.

=item *

No $r request object. No mod_perl integration or configuration capability.

=back

Contributed patches to add these features of HTML::Mason would be
welcomed by the author. Possible implemenations are described in
L<Text::MicroMason::ToDo>.

=head2 Private Methods

The following internal methods are used to implement the syntax described below.

=over 4

=item lex_token

  ( $type, $value ) = $mason->lex_token();

Supports HTML::Mason's markup syntax.

Attempts to parse a token from the template text stored in the global $_ and returns a token type and value. Returns an empty list if unable to parse further due to an error.

=item assembler_rules()

Returns a hash of text elements used for Perl subroutine assembly. Used by assemble(). 

Supports HTML::Mason's named blocks of Perl code and documentation: %once, %init, %cleanup, and %doc.

=item assemble_args

Called by assemble(), this method provides support for Mason's <%args> blocks.

=back


=head1 TEMPLATE SYNTAX

Here's an example of Mason-style templating, taken from L<HTML::Mason>:

    % my $noun = 'World';
    Hello <% $noun %>!
    How are ya?

Interpreting this template with Text::MicroMason produces the same output as it would in HTML::Mason:

    Hello World!
    How are ya?

Text::MicroMason::HTMLMason supports a syntax that is mostly a subset of that used by HTML::Mason.

=head2 Template Markup

The following types of markup are recognized in template pages:

=over 4

=item *

I<literal_text>

Anything not specifically parsed by one of the below rules is interpreted as literal text.

=item *

E<lt>% I<perl_expr> %E<gt>

A Perl expression to be interpolated into the result.

For example, the following template text will return a scheduled
greeting:

    Good <% (localtime)[2]>11 ? 'afternoon' : 'morning' %>.

The block may span multiple lines and is scoped inside a "do" block,
so it may contain multiple Perl statements and it need not end with
a semicolon.

    Good <% my $h = (localtime)[2]; $h > 11 ? 'afternoon' 
                                            : 'morning'  %>.

=item *

% I<perl_code>

Lines which begin with the % character, without any leading
whitespace, may contain arbitrary Perl code to be executed when
encountering this portion of the template.  Their result is not
interpolated into the result.

For example, the following template text will return a scheduled
greeting:

    % my $daypart = (localtime)[2]>11 ? 'afternoon' : 'morning';
    Good <% $daypart %>.

The line may contain one or more statements.  This code is is not
placed in its own block scope, so it should typically end with a
semicolon; it can still open a spanning block scope closed by a later
perl block.

For example, the following template text will return one of two different messages each time it's interpreted:

    % if ( int rand 2 ) {
      Hello World!
    % } else {
      Goodbye Cruel World!
    % }

This also allows you to quickly comment out sections of a template by prefacing each line with C<% #>.

This is equivalent to a <%perl>...</%perl> block.

=item *

E<lt>& I<template_filename>, I<arguments> &E<gt>

Includes the results of a separate file containing MicroMason code, compiling it and executing it with any arguments passed after the filename.

For example, we could place the following template text into an separate 
file:

    Good <% $ARGS{hour} >11 ? 'afternoon' : 'morning' %>.

Assuming this file was named "greeting.msn", its results could be embedded within the output of another script as follows:

  <& "greeting.msn", hour => (localtime)[2] &>

=item *

E<lt>%I<name>E<gt> ... E<lt>/%I<name>E<gt>

A named block contains a span of text. The name at the start and end must match, and must be one of the supported block names. 

Depending on the name, performs one of the behaviors described in L</"Named Blocks">.

=back

=head2 Named Blocks

The following types of named blocks are supported:

=over 4

=item *

E<lt>%perlE<gt> I<perl_code> E<lt>/%perlE<gt>

Blocks surrounded by %perl tags may contain arbitrary Perl code.
Their result is not interpolated into the result.

These blocks may span multiple lines in your template file. For
example, the below template initializes a Perl variable inside a
%perl block, and then interpolates the result into a message.

    <%perl> 
      my $count = join '', map "$_... ", ( 1 .. 9 ); 
    </%perl>
    Here are some numbers: <% $count %>

The code may contain one or more statements.  This code is is not
placed in its own block scope, so it should typically end with a
semicolon; it can still open a spanning block scope closed by a later
perl block.

For example, when the below template text is evaluated it will
return a sequence of digits:

    Here are some numbers: 
    <%perl> 
      foreach my $digit ( 1 .. 9 ) { 
    </%perl>
	<% $digit %>... 
    <%perl> 
      } 
    </%perl>

If the block is immediately followed by a line break, that break is
discarded.  These blocks are not whitespace sensitive, so the template
could be combined into a single line if desired.

=item *

E<lt>%argsE<gt> I<variable> => I<default> E<lt>/%argsE<gt>

Defines a collection of variables to be initialized from named arguments passed to the subroutine. Arguments are separated by one or more newlines, and may optionally be followed by a default value. If no default value is provided, the argument is required and the subroutine will croak if it is not provided. 

For example, adding the following block to a template will initialize the three named variables, and will fail if no C<a =E<gt> '...'> argument pair is passed:

  <%args>
    $a
    @b => qw( foo bar baz )
    %c => ()
  </%args>

All the arguments are available as lexically scoped ("my") variables in the rest of the component. Default expressions are evaluated in top-to-bottom order, and one expression may reference an earlier one.

Only valid Perl variable names may be used in <%args> sections. Parameters with non-valid variable names cannot be pre-declared and must be fetched manually out of the %ARGS hash. 

=item *

E<lt>%initE<gt> I<perl_code> E<lt>/%initE<gt>

Similar to a %perl block, except that the code is moved up to the start of
the subroutine. This allows a template's initialization code to be moved to
the end of the file rather than requiring it to be at the top.

For example, the following template text will return a scheduled
greeting:

    Good <% $daypart %>.
    <%init> 
      my $daypart = (localtime)[2]>11 ? 'afternoon' : 'morning';
    </%init>

=item *

E<lt>%cleanupE<gt> I<perl_code> E<lt>/%cleanupE<gt>

Similar to a %perl block, except that the code is moved down to the end of the subroutine. 

=item *

E<lt>%onceE<gt> I<perl_code> E<lt>/%onceE<gt>

Similar to a %perl block, except that the code is executed once,
when the template is first compiled. (If a caller is using execute,
this code will be run repeatedly, but if they call compile and then
invoke the resulting subroutine multiple times, the %once code will
only execute during the compilation step.)

This code does not have access to %ARGS and can not generate output.
It can be used to define constants, create persistent variables,
or otherwise prepare the environment.

For example, the following template text will return a increasing
number each time it is called:

    <%once> 
      my $counter = 1000;
    </%once>
    The count is <% ++ $counter %>.

=item *

E<lt>%docE<gt> ... E<lt>/%docE<gt>

Provides space for template developer documentation or comments which are not included in the output.

=item *

E<lt>%textE<gt> ... E<lt>/%textE<gt>

Produces literal text in the template output. Can be used to surround text
that contains other markup tags that should not be interpreted.

Equivalent to un-marked-up text.

=back

The following types of named blocks are not supported by HTML::Mason, but are supported here as a side-effect of the way the lexer and assembler are implemented.

=over 4

=item *

E<lt>%exprE<gt> ... E<lt>/%exprE<gt>

A Perl expression to be interpolated into the result.
The block may span multiple lines and is scoped inside a "do" block,
so it may contain multiple Perl statements and it need not end with
a semicolon. 

Equivalent to the C<E<lt>% ... %E<gt>> markup syntax.

=item *

E<lt>%fileE<gt> I<template_filename>, I<arguments> E<lt>/%fileE<gt>

Includes the results of a separate file containing MicroMason code, compiling it and executing it with any arguments passed after the filename.

  <%file> "greeting.msn", hour => (localtime)[2] </%file>

Equivalent to the C<E<lt>& ... &E<gt>> markup syntax.

=back


=head1 TEMPLATE CODING TECHNIQUES

=head2 Assembling Perl Source Code

When Text::MicroMason::Base assembles your lexed template into the
equivalent Perl subroutine, all of the literal (non-Perl) pieces are
converted to C<$_out-E<gt>('text');> statements, and the interpolated
expressions are converted to C<$_out-E<gt>( do { expr } );> statements.
Code from %perl blocks and % lines are included exactly as-is.

Your code is eval'd in the C<Text::MicroMason::Commands> package. 
The C<use strict;> pragma is enabled by default to simplify debugging.

=head2 Internal Sub-templates

You can create sub-templates within your template text by defining
them as anonymous subroutines and then calling them repeatedly.
For example, the following template will concatenate the results of 
the draw_item sub-template for each of three items:

    <h1>We've Got Items!</h1>
    
    % my $draw_item = sub {
      <p><b><% $_[0] %></b>:<br>
	<a href="/more?item=<% $_[0] %>">See more about <% $_[0] %>.</p>
    % };
    
    <%perl>
      foreach my $item ( qw( Foo Bar Baz ) ) {
	$draw_item->( $item );
      }
    </%perl>

=head2 Returning Text from Perl Blocks

To append to the result from within Perl code, call $_out->(I<text>). 
(The $_out->() syntax is unavailable in older versions of Perl; use the
equivalent &$_out() syntax instead.)

For example, the below template text will return '123456789' when it is
evaluated:

    <%perl>
      foreach my $digit ( 1 .. 9 ) {
	$_out->( $digit )
      }
    </%perl>

You can also directly manipulate the value @OUT, which contains the
accumulating result. 

For example, the below template text will return an altered version of its
message if a true value for 'minor' is passed as an argument when the
template is executed:

    This is a funny joke.
    % if ( $ARGS{minor} ) { foreach ( @OUT ) { tr[a-z][n-za-m] } }


=head1 SEE ALSO

For a full-featured web application system using this template syntax, see L<HTML::Mason>.

For an overview of this distribution, see L<Text::MicroMason>.

This is a subclass intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

