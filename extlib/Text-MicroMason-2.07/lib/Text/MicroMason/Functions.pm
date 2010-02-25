package Text::MicroMason::Functions;

use strict;
use vars qw( @ISA @EXPORT_OK );

use Exporter;
@ISA = 'Exporter';

@EXPORT_OK = ( 
  'compile',		# $code_ref = compile( $mason_text );
  'compile_file',	# $code_ref = compile_file( $filename );
  'safe_compile',	# $code_ref = safe_compile( $mason_text );
  'safe_compile_file',	# $code_ref = safe_compile_file( $filename );
  'execute',		# $result   = execute( $filename, %args );
  'execute_file',	# $result   = execute_file( $filename, %args );
  'safe_execute',	# $result   = safe_execute( $mason_text, %args );
  'safe_execute_file',	# $result   = safe_execute_file( $filename, %args );
);

push @EXPORT_OK, map "try_$_", @EXPORT_OK;

######################################################################

sub Mason { 
  () 
}

sub SafeMason {
  ( -Safe, (ref($_[0]) =~ /Safe/) ? (safe => shift) : () ) 
}

sub CatchingMason { 
  ( -CatchErrors );
}

sub SafeCatchingMason {
  ( -CatchErrors, -Safe, (ref($_[0]) =~ /Safe/) ? (safe => shift) : () ) 
}

foreach my $sub (@EXPORT_OK ) {
  no strict 'refs';
  my $method = $sub;
  my $source = ( $method =~ s/_file// ) ? 'file' : 'text';

  my $mason = "Mason";
  $mason = "Catching$mason" if ( $method =~ s/try_// );
  $mason = "Safe$mason" if ( $method =~ s/safe_// );
  *{__PACKAGE__."::$sub"} = sub {
    Text::MicroMason->new( &$mason )
		    ->$method( (ref($_[0]) eq 'CODE') ? 'code' : $source => @_ ) 
  }
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::Functions - Function Exporter for Simple Mason Templates


=head1 SYNOPSIS

Use the execute function to parse and evalute a template:

    use Text::MicroMason::Functions qw( execute );
    print execute($template, 'name'=>'Dave');

Or compile it into a subroutine, and evaluate repeatedly:

    use Text::MicroMason::Functions qw( compile );
    $coderef = compile($template);
    print $coderef->('name'=>'Dave');
    print $coderef->('name'=>'Bob');

Templates stored in files can be run directly or included in others:

    use Text::MicroMason::Functions qw( execute_file );
    print execute_file( "./greeting.msn", 'name'=>'Charles');

Safe usage restricts templates from accessing your files or data:

    use Text::MicroMason::Functions qw( safe_execute );
    print safe_execute( $template, 'name'=>'Bob');

All above functions are available in an error-catching "try_*" form:

    use Text::MicroMason::Functions qw( try_execute );
    ($result, $error) = try_execute( $template, 'name'=>'Alice');


=head1 DESCRIPTION

As an alternative to the object-oriented interface, text containing MicroMason markup code can be compiled and executed by calling the following functions. 

Please note that this interface is maintained primarily for backward compatibility with version 1 of Text::MicroMason, and it does not provide access to some of the newer features.

Each function creates a new MicroMason object, including any necessary traits such as Safe compilation or CatchErrors for exceptions, and then passes its arguments to an appropriate method on that object.

You may import any of these functions by including their names in your 
C<use Text::MicroMason> statement.

=head2 Basic Invocation

To evaluate a Mason-like template, pass it to execute():

  $result = execute( $mason_text );

Alternately, you can call compile() to generate a subroutine for your template, and then run the subroutine:

  $result = compile( $mason_text )->();

If you will be interpreting the same template repeatedly, you can save the compiled version for faster execution:

  $sub_ref = compile( $mason_text );
  $result = $sub_ref->();

(Note that the $sub_ref->() syntax is unavailable in older versions of Perl; use the equivalent &$sub_ref() syntax instead.)

=head2 Argument Passing

You can also pass a list of key-value pairs as arguments to execute, or to the compiled subroutine:

  $result = execute( $mason_text, %args );
  
  $result = $sub_ref->( %args );

Within the scope of your template, any arguments that were provided will be accessible in the global @_, the C<%ARGS> hash, and any variables named in an %args block.

For example, the below calls will all return '<b>Foo</b>':

  execute('<b><% shift(@_) %></b>', 'Foo');
  execute('<b><% $ARGS{label} %></b>', label=>'Foo');
  execute('<%args>$label</%args><b><% $label %></b>', label=>'Foo');

=head2 Template Files

A parallel set of functions exist to handle templates which are stored in a file:

  $template = compile_file( './report_tmpl.msn' );
  $result = $template->( %args );

  $result = execute_file( './report_tmpl.msn', %args );

Template documents are just plain text files that contains the string to be parsed. The files may have any name you wish, and the .msn extension shown above is not required.

=head2 Error Checking

Both compilation and run-time errors in your template are handled as fatal
exceptions. The provided try_execute() and try_compile() functions use a mixin class which wraps an eval { } block around the basic execute() or compile()
methods. In a scalar context they return the result of the call, or
undef if it failed; in a list context they return the results of the call
(undef if it failed) followed by the error message (undef if it succeeded).
For example:

  ($result, $error) = try_execute( $mason_text );
  if ( ! $error ) {
    print $result;
  } else {
    print "Unable to execute template: $error";
  }

A matching pair of try_*_file() wrappers are available to catch run-time errors in reading a file or parsing its contents:

  ($template, $error) = try_compile_file( './report_tmpl.msn' );

  ($result, $error) = try_execute_file( './report_tmpl.msn', %args );

For more information, see L<Text::MicroMason::CatchErrors>.

=head2 Safe Compartments

If you wish to restrict the operations that a template can perform,
use the safe_compile() and safe_execute() functions, or their
try_*() wrappers.

For more information, see L<Text::MicroMason::Safe>.


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
