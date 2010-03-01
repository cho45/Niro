package Text::MicroMason::CatchErrors;

use strict;
use Carp;

######################################################################

# sub defaults {
#   (shift)->NEXT('assembler_rules'), error_string => 1
# }

sub compile {
  my $result = eval { local $SIG{__DIE__}; (shift)->NEXT('compile', @_) };
  wantarray ? ($result, $@) : $result;
}

sub execute {
  my $result = eval { local $SIG{__DIE__}; (shift)->NEXT('execute', @_) };
  wantarray ? ($result, $@) : $result;
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::CatchErrors - Add Exception Catching for Templates


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason->new( -CatchErrors );

Use the standard compile and execute methods to parse and evalute templates:

  print scalar $mason->compile( text=>$template )->( @%args );
  print scalar $mason->execute( text=>$template, @args );

Result is undef on exception, plus an error message if in list context:

  ($coderef, $error) = $mason->compile( text=>$template );
  ($result,  $error) = $mason->execute( text=>$template, 'name'=>'Dave' );


=head1 DESCRIPTION

This package adds exception catching to MicroMason, allowing you to check
an error variable rather than wrapping every call in an eval.

Both compilation and run-time errors in your template are handled as fatal
exceptions. The base MicroMason class will croak() if you attempt to
compile or execute a template which contains a incorrect fragment of Perl
syntax. Similarly, if the Perl code in your template causes die() or
croak() to be called, this will interupt your program unless caught by an
eval block.

This class provides that error catching behavior for the compile and
execute methods.

In a scalar context they return the result of the call, or undef if it
failed; in a list context they return the results of the call (undef if
it failed) followed by the error message (undef if it succeeded).

=head2 Public Methods

=over 4

=item compile()

  $code_ref = $mason->compile( text => $template, %options );
  ($coderef, $error) = $mason->compile( text=>$template, %options );

Uses an eval block to provide an exception catching wrapper for the compile method.

=item execute()

  $result = $mason->execute( text => $template, @arguments );
  ($result,  $error) = $mason->execute( text=>$template, 'name'=>'Dave' );

Uses an eval block to provide an exception catching wrapper for the execute method.

=back


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

