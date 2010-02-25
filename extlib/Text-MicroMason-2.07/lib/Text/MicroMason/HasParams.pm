package Text::MicroMason::HasParams;

######################################################################

sub defaults {
  (shift)->NEXT('defaults'), params => [ {} ]
}

######################################################################

sub assembler_rules {
  my $self = shift;
  $self->NEXT('assembler_rules', @_),
    init_args => 'local $m->{params} = [ ( @_ == 1 ) ? $_[0] : scalar(@_) ? { @_ } : (), $m->{params} ? @{$m->{params}} : () ];';
}

######################################################################

sub param {
  my $self = shift;

  my @params = $self->{params} ? @{$self->{params}} : ();
  
  if ( scalar @_ == 0 ) {
    return map( keys(%$_), @params ),
	    $self->{associate} ? $self->{associate}->param() : ()

  } elsif ( scalar @_ > 1 ) {
    if ( my $associate = $self->{associate} ) {
      return $associate->param( @_ );
    }
    $self->{params} ||= [ {} ];
    $self->{params}[0] ||= {};
    my $target = $self->{params}[0];
    if ( $self->{case_sensitive} ) { 
      %$target = ( %$target, @_ );
    } else {
      my %hash = @_;
      %$target = ( %$target, map { lc($_) => $hash{$_} } keys %hash );
      # warn "set params $self->{params}[0]: " , %{ $self->{params}[0] };
    }

  } elsif ( scalar @_ == 1 and ref( $_[0] ) ) {
    push @{$self->{params}}, shift();

  } else {
    my $key = $self->{case_sensitive} ? shift : lc( shift );
    # warn "get params $key: $#params\n";
    foreach my $param ( @params ) {
      # warn "get params $param: $key\n";
      my $case_key = ( exists $param->{ $key } ) ? $key : 
	( ! $self->{case_sensitive} ) ? ( grep { lc eq $key } keys %$param )[0] : undef;
      next unless defined $case_key;
      my $value = $param->{ $case_key };
      # warn "get params $param: $key ($case_key) = $value\n";
      return( ( ref($value) eq 'ARRAY' ) ? @$value : $value )
    }
    if ( my $associate = $self->{associate} ) {
      my $case_key = ( $self->{case_sensitive} ) ? $key : 
		( grep { lc eq $key } $associate->param() )[0];
      return $associate->param( $case_key );
    }
    return;
  }
}

######################################################################

1;

__END__

######################################################################

=head1 DESCRIPTION

This mixin class ...

'
=head2 Public Methods

=over 4

=item param()

Gets and sets parameter arguments. Similar to the param() method provied by HTML::Template and the CGI module.

=back


=head2 Private Methods

=over 4

=item assembler_rules()

Adds initialization for param() at the begining of each subroutine to be compiled.

=back


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

