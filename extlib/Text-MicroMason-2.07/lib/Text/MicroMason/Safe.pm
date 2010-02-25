package Text::MicroMason::Safe;

use strict;
use Carp;

use Safe;

######################################################################

sub eval_sub {
  my ( $self, $code ) = @_;

  my $safe = $self->safe_compartment();

  local $Text::MicroMason::Commands::m = $self->safe_facade();
  $safe->share_from( 'Text::MicroMason::Commands' => [ '$m' ] );

  $safe->reval( "my \$m = \$m; $code", 1 )
}

# $self_or_safe = $mason->safe_compartment();
sub safe_compartment {
  my $self = shift;
  
  if ( ! $self->{safe} or $self->{safe} eq '1' ) {
    return Safe->new()
  } elsif ( UNIVERSAL::can( $self->{safe}, 'reval' ) ) {
    return $self->{safe}
  } else {
    $self->croak_msg("Inappropriate Safe compartment:", $self->{safe});
  }
}

sub safe_facade {
  my $self = shift;
  Text::MicroMason::Safe::Facade->new(
    map { 
      my $method = $_; 
      $_ => sub { $self->$method( @_ ) } 
    }
    map { ! $_ ? () : ref($_) ? @$_ : split ' ' } $self->{safe_methods} 
  )
}

######################################################################

package Text::MicroMason::Safe::Facade;

sub new { 
  my $class = shift;
  bless { @_ }, $class
}

sub facade_method {
  my ( $self, $method, @args ) = @_;
  my $sub = $self->{$method} 
      or die "Can't call \$m->$method() in this compartment";
  &$sub( @args )
}

sub AUTOLOAD {
  my $sym = $Text::MicroMason::Safe::Facade::AUTOLOAD;
  my ($package, $func) = ($sym =~ /(.*)::([^:]+)$/);
  return unless ( $func =~ /^[a-z\_]+$/ );
  no strict;
  my $sub = *{$func} = sub { (shift)->facade_method($func, @_ ) };
  goto &$sub;
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::Safe - Compile all Templates in a Safe Compartment


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

  use Text::MicroMason;
  my $mason = Text::MicroMason->new( -Safe );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

Safe usage restricts templates from accessing your files or data:

  print $mason->execute( text=>"<% qx! cat /etc/passwd ! %>" ); # dies

  print $mason->execute( text=>"The time is <% time() %>." ); # dies


=head1 DESCRIPTION

This package adds support for Safe compartments to MicroMason, allowing 
you to  restrict the operations that a template can perform.

By default, these safe calls prevent the code in a template from performing
any system activity or accessing any of your other Perl code.  Violations
may result in either compile-time or run-time errors, so make sure you
are using an eval block or the CatchErrors trait to catch exceptions.

  use Text::MicroMason;
  my $mason = Text::MicroMason->new( -Safe );

  $result = eval { $mason->execute( text => $template ) };

B<Caution:> Although this appears to provide a significant amount of security for untrusted templates, please take this with a grain of salt. A bug in either this module or in the core Safe module could allow a clever attacker to defeat the protection. At least one bug in the Safe module has been found and fixed in years past, and there could be others. 

=head2 Supported Attributes

=over 4

=item safe

Optional reference to a Safe compartment. If you do not provide this, one
is generated for you.

To enable some operations or share variables or functions with the template
code, create a Safe compartment and configure it before passing it in as
the value of the "safe" attribute:

  $safe = Safe->new();
  $safe->permit('time');
  $safe->share('$foo');

  $mason = Text::MicroMason->new( -Safe, safe => $safe );

  $result = eval { $mason->execute( text => $template ) };

=item safe_methods

A space-separated string of methods names to be supported by the Safe::Facade.

To control which Mason methods are available within the template, pass a
C<safe_methods> argument to new() followed by the method names in a 
space-separated string.

For example, to allow templates to include other templates, using $m->execute
or the "<& file &>" include syntax, you would need to allow the execute
method. We'll also load the TemplateDir mixin with strict_root on to prevent
inclusion of templates from outside the current directory.

  $mason = Text::MicroMason->new( -Safe, safe_methods => 'execute', 
				  -TemplateDir, strict_root => 1 );

If you're combining this with the Filters mixin, you'll also need to allow
calls to the filter method; to allow multiple methods, join their names
with spaces:

  $mason = Text::MicroMason->new( -Safe, safe_methods => 'execute filter', 
				  -TemplateDir, strict_root => 1,
				  -Filters );

=back

=head2 Private Methods

=over 4

=item eval_sub()

Instead of the eval() used by the base class, this calls reval() on a Safe
compartment.

=item safe_compartment()

Returns the Safe compartment passed by the user or generates a new one.

=item safe_facade()

Generates an instance of the Safe::Facade equipped with only the methods
listed in the safe_methods attribute.

=back


=head2 Private Safe::Facade class

Code compiled in a Safe compartment only has access to a limited version of
the template compiler in the $m variable, and can not make changes to the
attributes of the real MicroMason object. This limited object is an instance
of the Text::MicroMason::Safe::Facade class and can only perform certain
pre-defined methods.

=over 4

=item new()

Creates a new hash-based instance mapping method names to subroutine
references.

=item facade_method()

Calls a named method by looking up the corresponding subroutine and calling
it.

=item AUTOLOAD()

Generates wrapper methods that call the facade_method() for any lowercase
method name.

=back


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
