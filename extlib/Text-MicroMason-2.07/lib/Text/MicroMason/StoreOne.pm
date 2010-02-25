package Text::MicroMason::StoreOne;

######################################################################

sub create {
  my ( $class, %options ) = @_;
  my @compile; 
  if ( my $file = delete $options{filename} ) {
    @compile = ( 'file' => $file );
  } elsif ( my $string = delete $options{text} ) {
    @compile = ( 'text' => $string );
  } 
  my $self = $class->NEXT('create', %options);
  $self->compile( @compile ) if @compile;
  $self;
}

sub compile {
  my $self = shift;
  my $sub = $self->NEXT('compile', @_);
  $self->{last_compile} = $sub;
}

sub execute_again {
  my $self = shift;
  my $sub = $self->{last_compile} 
	or $self->croak_msg("No template has been compiled yet");
  &$sub( @_ );
}

######################################################################

1;

__END__

######################################################################

=head1 DESCRIPTION

This mixin class ...


=head2 Public Methods

=over 4

=item compile()

Caches a reference to the most-recently compiled subroutine in the Mason object.

=item execute_again()

Executes the most-recently compiled template and returns the results.

Optionally accepts a filehandle to print the results to.

  $template->output( print_to => *STDOUT );

=back


=head2 Private Methods

=over 4

=item create()

Creates a new Mason object. If a string or filename parameter is supplied, the corresponding template is compiled.

=back

=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

