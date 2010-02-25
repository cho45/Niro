package Text::MicroMason;
$VERSION = '2.07';

# The #line directive requires Perl 5.6 to work correctly the way we use
# it in Base.
require 5.006;
use strict;

require Text::MicroMason::Base;

######################################################################

sub import {
  shift;
  return unless ( @_ );
  require Exporter; 
  require Text::MicroMason::Functions; 
  unshift @_, 'Text::MicroMason::Functions'; 
  goto &Exporter::import
}

######################################################################

sub class {
  shift;
  Text::MicroMason::Base->class( @_, 'HTMLMason' );
}

sub new { 
  shift; 
  Text::MicroMason::Base->new( @_, '-HTMLMason' ) 
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason - Simple and Extensible Templating


=head1 SYNOPSIS

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

Create a MicroMason object to interpret the templates:

    use Text::MicroMason;
    $mason = Text::MicroMason->new();

Use the compile method to convert templates into a subroutines:

    $coderef = $mason->compile( text=>$template );
    print $coderef->('name'=>'Alice');

Or use the execute method to parse and evalute in one call:

    print $mason->execute( text=>$template, 'name'=>'Bob' );

Templates stored in files can be run directly or included in others:

    print $mason->execute( file=>"./greeting.msn", 'name'=>'Charles');

For additional features, select mixin classes to add to your MicroMason object:

    $mason = Text::MicroMason->new( qw( -CatchErrors -Safe -Filters ) );

You can import various functions if you prefer to avoid method calls:

    use Text::MicroMason::Functions qw( compile execute );

    print execute($template, 'name'=>'Dave');

    $coderef = compile($template);
    print $coderef->('name'=>'Bob');


=head1 DESCRIPTION

Text::MicroMason interpolates blocks of Perl code embedded into text
strings.

Each MicroMason object acts as a "template compiler," which converts
templates from text-with-embedded-code formats into ready-to-execute
Perl subroutines.

=head2 MicroMason Initialization

Use the new() method to create a Text::MicroMason object with the
appropriate mixins and attributes.

  $mason = Text::MicroMason->new( %attribs );

You may pass attributes as key-value pairs to the new() method to save
various options for later use by the compile() method.

=head2 Template Compilation

To compile a text template, pass it to the compile() method to produce a
new Perl subroutine to be returned as a code reference:

  $code_ref = $mason->compile( $type => $source, %attribs );

Any attributes provided to compile() will temporarily override the
persistant options defined by new(), for that template only.

You can provide the template as a text string, a file name, or an open
file handle:

  $code_ref = $mason->compile( text => $template );
  $code_ref = $mason->compile( text => \$template );
  $code_ref = $mason->compile( file => $filename );
  $code_ref = $mason->compile( handle => $fh );
  $code_ref = $mason->compile( handle => \*FILE );

Template files are just plain text files that contains the string to be
parsed. The files may have any name and extension you wish. The filename
specified can either be absolute or relative to the program's current
directory.

=head2 Template Execution

To execute the template and obtain the output, call a compiled function:

  $result = $code_ref->( @arguments );

(Note that the $code_ref->() syntax is unavailable in older versions of
Perl; use the equivalent &$code_ref() syntax instead.)

As a shortcut, the execute method compiles and runs the template one time:

  $result = $mason->execute( $type => $source, @arguments );
  $result = $mason->execute( $type => $source, \%attribs, @arguments );

=head2 Argument Passing

You can pass arguments to a template subroutine using positional or
named arguments.

For positional arguments, pass the argument list and read from @_ as usual:

  $mason->compile( text=>'Hello <% shift(@_) %>.' )->( 'Dave' );

For named arguments, pass in a hash of key-value pairs to be made
accessible in an C<%ARGS> hash within the template subroutine:

  $mason->compile( text=>'Hello <% $ARGS{name} %>.' )->( name=>'Dave' );

Additionally, you can use named arugments with the %args block syntax:

  $mason->compile( text=>'%args>$label</%args>Hello <% $label %>.' )->( name=>'Dave' );

=head2 Mixin Selection

Arguments passed to new() that begin with a dash will be added as mixin classes.

  $mason = Text::MicroMason->new( -Mixin1, %attribs, -Mixin2 );

Every MicroMason object inherits from an abstract Base class and some
set of mixin classes. By combining mixins you can create subclasses with
the desired combination of features. See L<Text::MicroMason::Base> for
documentation of the base class, including private methods and extension
mechanisms.

If you call the new method on Text::MicroMason, it automatically
includes the HTMLMason mixin, which provides the standard template
syntax. If you want to create an object without the default HTMLMason
functionality, call Text::MicroMason::Base->new() instead.

Some mixins define the syntax for a particular template format. You will
generally need to select one, and only one, of the mixins listed in
L</"TEMPLATE SYNTAXES">.

Other mixins provide optional functionality. Those mixins may define
additional public methods, and may support or require values for various
additional attributes. For a list of such mixin classes, see L</"MIXIN
FEATURES">.


=head1 TEMPLATE SYNTAXES

Templates contain a mix of literal text to be output with some type of
markup syntax which specifies more complex behaviors.

The Text::MicroMason::HTMLMason mixin is selected by default. To enable
an alternative, pass its name to Text::MicroMason::Base->new( -
MixinName ).

=head2 HTMLMason

The HTMLMason mixin provides lexer and assembler methods that handle
most elements of HTML::Mason's template syntax.

  my $mason = Text::MicroMason::Base->new( -HTMLMason );
  my $output = $mason->execute( text => $template, name => 'Bob' );

    <%args>
      $name => 'Guest' 
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

For a definition of the template syntax, see L<Text::MicroMason::HTMLMason>.

=head2 DoubleQuote

The DoubleQuote mixin uses Perl's double-quoting interpolation as a
minimalist syntax for templating.

  my $mason = Text::MicroMason::Base->new( -DoubleQuote );
  my $output = $mason->execute( text => $template, name => 'Bob' );

    ${ $::hour = (localtime)[2];
      $::daypart = ( $::hour > 11 ) ? 'afternoon' : 'morning'; 
    \'' }
    Good $::daypart, $ARGS{name}!

For more information see L<Text::MicroMason::DoubleQuote>.

=head2 Embperl

The Embperl mixin support a template syntax similar to that used by the
HTML::Embperl module.

  my $mason = Text::MicroMason::Base->new( -Embperl );
  my $output = $mason->execute( text => $template, name => 'Bob' );

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

For more information see L<Text::MicroMason::Embperl>.

=head2 HTMLTemplate

The HTMLTemplate mixin supports a syntax similar to that used by the
HTML::Template module.

  my $mason = Text::MicroMason::Base->new( -HTMLTemplate );
  my $output = $mason->execute( text => $template, name => 'Bob' );

    <TMPL_IF NAME="user_is_dave">
      I'm sorry <TMPLVAR NAME="name">, I'm afraid I can't do that right now.
    <TMPL_ELSE>
      <TMPL_IF NAME="daytime_is_morning">
	Good morning, <TMPLVAR NAME="name">!
      <TMPL_ELSE>
	Good afternoon, <TMPLVAR NAME="name">!
      </TMPL_IF>
    </TMPL_IF>

For more information see L<Text::MicroMason::HTMLTemplate>.

=head2 ServerPages

The ServerPages mixin supports a syntax similar to that used by the
Apache::ASP module.

  my $mason = Text::MicroMason::Base->new( -ServerPages );
  my $output = $mason->execute( text => $template, name => 'Bob' );

    <% my $name = $ARGS{name};
      if ( $name eq 'Dave' ) {  %>
      I'm sorry <%= $name %>, I'm afraid I can't do that right now.
    <% } else { 
	my $hour = (localtime)[2];
	my $daypart = ( $hour > 11 ) ? 'afternoon' : 'morning'; 
      %>
      Good <%= $daypart %>, <%= $name %>!
    <% } %>

For more information see L<Text::MicroMason::ServerPages>.

=head2 Sprintf

The Sprintf mixin uses Perl's sprintf formatting syntax for templating.

  my $mason = Text::MicroMason::Base->new( -Sprintf );
  my $output = $mason->execute( text => $template, 'morning', 'Bob' );

    Good %s, %s!

For more information see L<Text::MicroMason::Sprintf>.

=head2 TextTemplate

The TextTemplate mixin supports a syntax similar to that used by the
Text::Template module.

  my $mason = Text::MicroMason::Base->new( -TextTemplate );
  my $output = $mason->execute( text => $template, name => 'Bob' );

    { $hour = (localtime)[2];
      $daypart = ( $hour > 11 ) ? 'afternoon' : 'morning'; 
    '' }
    Good { $daypart }, { $name }!

For more information see L<Text::MicroMason::TextTemplate>.


=head1 MIXIN FEATURES

The following mixin classes can be layered on to your MicroMason object
to provide additional functionality.

To add a mixin's functionality, pass it's name with a dash to the new() method:

  $mason = Text::MicroMason->new( -CatchErrors, -PostProcess );

=head2 AllowGlobals

Enables access to a set of package variables to be shared with templates. 

For details see L<Text::MicroMason::AllowGlobals>.

=head2 CatchErrors

Both compilation and run-time errors in your template are handled as
fatal exceptions. To prevent a template error from ending your program,
enclose it in an eval block:

  my $result = eval { $mason->execute( text => $template ) };
  if ( $@ ) {
    print "Unable to execute template: $@";
  } else {
    print $result;
  }

To transparently add this functionality to your MicroMason object, see
L<Text::MicroMason::CatchErrors>.

=head2 CompileCache

Calling execute repeatedly will be slower than compiling once and
calling the template function repeatedly, unless you enable
compilation caching.

For details see L<Text::MicroMason::CompileCache>.

=head2 Debug

When trying to debug a template problem, it can be helpful to watch the
internal processes of template compilation. This mixin adds controllable
warning messages that show the intermediate parse information.

For details see L<Text::MicroMason::Debug>.

=head2 LineNumbers

Provide better line numbers when compilation fails, at the cost of
potentially slower compilation and execution.

For details see L<Text::MicroMason::LineNumbers>.

=head2 ExecuteCache

Each time you execute the template all of the logic will be re-
evaluated, unless you enable execution caching, which stores the output
of each template for each given set of arguments.

For details see L<Text::MicroMason::ExecuteCache>.

=head2 Filters

HTML::Mason provides an expression filtering mechanism which is
typically used for applying HTML and URL escaping functions to output.

  Text::MicroMason->new(-Filters)->compile( text => $template );

  <p> Hello <% $name |h %>!

The Filters mixin provides this capability for Text::MicroMason
templates. To select it, add its name to your Mason initialization call:

  my $mason = Text::MicroMason->new( -Filters );

Output expressions may then be followed by "|h" or "|u" escapes; for
example this line would convert any ampersands in the output to the
equivalent HTML entity:

  Welcome to <% $company_name |h %>

For more information see L<Text::MicroMason::Filters>.

=head2 PassVariables

Allows you to pass arguments to templates as variables instead of the
basic argument list.

For details see L<Text::MicroMason::PostProcess>.

=head2 PostProcess

Allows you to specify one or more functions through which all template
output should be passed before it is returned.

For details see L<Text::MicroMason::PostProcess>.

=head2 Safe

By default, the code embedded in a template has accss to all of the
capabilities of your Perl process, and could potentially perform
dangerous activities such as accessing or modifying files and starting
other programs.

If you need to execute untrusted templates, use the Safe module,
which can restrict the operations and data structures that template
code can access.

To add this functionality to your MicroMason object, see
L<Text::MicroMason::Safe>.

=head2 TemplateDir

The filenames passed to the compile() or execute() methods can be looked
up relative to a base directory path or the current template file.

To add this functionality to your MicroMason object, see
L<Text::MicroMason::TemplateDir>.

=head2 TemplatePath

The filenames passed to the compile() or execute() methods are looked up
relative to a list of multiple base directory paths, in order. It tries
as hard as possible to maintain compatibility with caching and <& &>
template includes.

To add this functionality to your MicroMason object, see
L<Text::MicroMason::TemplatePath>.


=head1 OTHER INTERFACES

=head2 Function Exporter

Importable functions are provided for users who prefer a procedural interface. 

The supported functions are listed in L<Text::MicroMason::Functions>.
(For backwards compatibility, those functions can also be imported from
the main Text::MicroMason package.)

=head2 Template Frameworks

Adaptor modules are available to use MicroMason from within other frameworks. 
For more information, see L<Any::Template::Backend::Text::MicroMason> and
L<Catalyst::View::MicroMason>.

=head2 Inline

MicroMason templates can be embbeded within your source code using Inline. 
For more information, see L<Inline::Mason>.


=head1 EXCEPTIONS

Text::MicroMason croaks on error, with an appropriate error string. Some
commonly occurring error messages are described below (where %s
indicates variable message text). See also the pod for each mixin class,
for additional exception strings that may be thrown.

=over 4

=item *

MicroMason parsing halted at %s

Indicates that the parser was unable to finish tokenising the source
text. Generally this means that there is a bug somewhere in the regular
expressions used by lex().

(If you encounter this error, please feel free to file a bug report or
send an example of the error to the author using the addresses below,
and I'll attempt to correct it in a future release.)

=item *

MicroMason compilation failed: %s

The template was parsed succesfully, but the Perl subroutine declaration
it was converted to failed to compile. This is generally a result of a
syntax error in one of the Perl expressions used within the template.

=item * 

Error in template subroutine: %s

Additional diagnostic for compilation errors, showing the text of the
subroutine which failed to compile.

=item * 

Error in template file %s, interpreted as: %s

Additional diagnostic for compilation errors in external files, showing
the filename and the text of the subroutine which failed to compile.

=item * 

MicroMason execution failed: %s

After parsing and compiling the template succesfully, the subroutine was
run and caused a fatal exception, generally because that some Perl code
used within the template caused die() to be called (or an equivalent
function like croak or confess).

=item *

MicroMason: filename is missing or empty

One of the compile or execute methods was called with an empty or
undefined filename, or one of the compile_file or execute_file methods
was called with no arguments.

=item *

MicroMason can't read from %s: %s

One of the compile_file or execute_file functions was called but we were
unable to read the requested file, because the file path is incorrect or
we have insufficient priveleges to read that file.

=back


=head1 SEE ALSO

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
