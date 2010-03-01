package Text::MicroMason::AllowGlobals;

use strict;
use Carp;

######################################################################

sub allow_globals {
  my $self = shift;
  my $globals = $self->{allow_globals};
  my @current = ref( $globals ) ? @$globals :
  		! defined( $globals ) ? () : 
		split ' ' , $globals;
  
  if ( scalar @_ ) {
    my %once_each;
    @current = grep { ! ( $once_each{$_} ++ ) } @current, @_;
    $self->{allow_globals} = \@current;
  }
  
  wantarray ? @current : join(' ', @current);
}

######################################################################

sub set_globals {
  my ( $self, %globals ) = @_;
  
  my @globals = keys %globals;
  $self->allow_globals( @globals );
  
  my $sub = join( "\n", 
      $self->allow_globals_statement(),
      " sub { ",
	map( { 
	    my $var = $_;  $var =~ s/^[\@\%]/*/; $var =~ s/^(\w)/\$$1/; 
	    "$var = \$_[0]{'$_'};" 
	  } @globals ),
      " }"
  );
  
  $self->eval_sub( $sub )->( \%globals )
}

######################################################################

sub allow_globals_statement {
  my $self = shift;
  "use vars qw(" . $self->allow_globals() . ");"
}

sub assemble {
  my $self = shift;
  $self->NEXT('assemble', once => $self->allow_globals_statement(), @_);
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::AllowGlobals - Share package vars between templates


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason->new( -AllowGlobals );

Share package variables:

    $mason->set_globals( '$name' => 'Bob' );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->();
  print $mason->execute( text=>$template );

Then, in a template, you can refer to those globals:

    Welcome, <% $name %>! 


=head1 DESCRIPTION


=head2 Public Methods

=over 4 

=item set_globals()

Accepts a list of pairs of global variable names and corresponding values.

Adds each variable name to the allowed list and sets it to the initial value.

=item allow_globals()

Gets or sets the variables names to be allowed.

If called with arguments, adds them to the list.

Returns the variables to be allowed as a list, or as a space-separated string in scalar context.

=back

=head2 Supported Attributes

=over 4

=item allow_globals

Optional array or space-separated string of global variable names to be allowed.

=back

=head2 Private Methods

=over 4

=item assemble()

Adds the allow_globals_statement to each token stream before assembling it.

=item allow_globals_statement()

This method prepends the "use vars" statement needed for the template subroutines to compile.

=back


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::HTMLMason>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

