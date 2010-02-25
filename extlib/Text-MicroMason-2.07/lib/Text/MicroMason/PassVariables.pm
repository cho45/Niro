package Text::MicroMason::PassVariables;

use strict;

######################################################################

my $seqno = 0;
sub prepare {
  my $self = shift;
  $self->NEXT('prepare', @_,
    ( $self->{package} ? () : ( package => __PACKAGE__ . '::GEN' . $seqno++ ) )
  )
}

######################################################################

# Text elements used for subroutine assembly
sub assembler_rules {
  (shift)->NEXT('assembler_rules', @_), 
  template => [ qw( $eval_start $no_strict $sub_start $init_errs $init_output 
			      $init_args @perl $return_output $sub_end ) ],
  eval_start => 'package __PACKAGE__;',
  no_strict => 'no strict;',
  init_args => 'local %__PACKAGE__:: = %__PACKAGE__::;' . "\n" .
			  'my %ARGS = @_;' . "\n" .
			  '$m->install_args_hash( "__PACKAGE__", \%ARGS );',
}

sub assemble {
  my $self = shift;
  my $code = $self->NEXT('assemble', @_);
  my $package = $self->{package} || 'Text::MicroMason::Commands';
  $code =~ s/(\S)__PACKAGE__/$1$package/g;
  $code =~ s/__PACKAGE__(\S)/$package$1/g;
  return $code;
}

######################################################################

# $mason->install_args_hash( $package, $hash_ref )
sub install_args_hash {
  my ($self, $dest, $hash) = @_;
  foreach my $name (keys %$hash) {
    my $val = $hash->{$name};
    my $sym = $dest . "::" . $name;
    no strict 'refs';
    # This code is cloned from Text::Template
    local *SYM = *{$sym};
    if (! defined $val) {
      delete ${"${dest}::"}{$name};
    } elsif (ref $val) {
      *SYM = $val;
    } else {
      *SYM = \$val;
    }
  }
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::PassVariables - Pass template data as variables


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

  use Text::MicroMason;
  my $mason = Text::MicroMason->new( -PassVariables );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( 'name'=>'Dave' );
  print $mason->execute( text=>$template, 'name'=>'Dave' );

Templates can now access their arguments as global variables:

  Welcome, <% $name %>! 


=head1 DESCRIPTION

Like Text::Template, this package passes in template arguments as package
variables. For example, if you pass in an argument list of C<foo =E<gt> 23>,
it will set the variable $foo in the package your template is compiled in.
This allows template code to refer to $name rather than $ARGS{name}.

The strict pragma is disabled to facilitate these variable references.

B<Caution:> Please note that this approach has some drawbacks, including the
risk of clobbering global variables used for other purposes. It is included
primarily to allow the TextTemplate module to emulate the behavior of
Text::Template, and for quick-and-dirty simple templates where succinctness
is more important than robustness.

=head2 Supported Attributes

=over 4

=item package

Target package namespace. Defaults to Text::MicroMason::Commands.

=back

=head2 Private Methods

=over 4

=item assembler_rules()

Adds Perl fragments to handle package and symbol table munging.

=item assemble()

Modifies Perl subroutine to embed the target package namespace.

=item install_args_hash()

Performs symbol table munging to transfer the contents of an arguments hash 
into variables in a target namespace. 

=back


=head1 SEE ALSO

The interface being emulated is described in L<Text::Template>.

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

