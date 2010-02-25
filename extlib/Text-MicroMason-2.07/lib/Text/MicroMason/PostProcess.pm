package Text::MicroMason::PostProcess;

use strict;
use Carp;

######################################################################

sub assembler_rules {
  my $self = shift;
  my %rules = $self->NEXT('assembler_rules', @_);
  $rules{return_output} = "\$m->post_process( $rules{return_output} )";
  %rules;
}

sub post_processors {
  my $self = shift;
  my $funcs = $self->{post_process};
  my @funcs = ref($funcs) eq 'ARRAY' ? @$funcs : $funcs ? $funcs : ();
  if ( scalar @_ ) {
    @funcs = ( $#_ == 0 and ref($_[0]) eq 'ARRAY' ) ? @{ $_[0] } : (@funcs, @_);
    $self->{post_process} = [ @funcs ];
  }
  return @funcs;
}

sub post_process {
  my $self = shift;
  local $_ = shift;
  foreach my $func ( $self->post_processors ) {
    my $p = prototype($func);
    if ( defined $p and ! length $p ) {
      &$func;
    } else {
      $_ = &$func( $_ );
    }
  }
  $_;
}

######################################################################

1;

__END__

=head1 NAME

Text::MicroMason::PostProcess - Apply Filters to All Template Output


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason->new( -PostProcess );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

You can define output filters at creation or subsequently:

    $mason = Text::MicroMason->new( -PostProcess, post_process => $func );

    $mason->post_processors( $func );

    $mason->compile( text => $template, post_process => $func );

    $mason->execute( text => $template, { post_process => $func }, @args );


=head1 DESCRIPTION

This mixin class adds filtering of all template output to any MicroMason class.

Filter functions can accept the string to be output and return a filtered version:

  $mason->post_process( sub {
    my $foo = shift;
    $foo =~ s/a-Z/A-Z/;
    return $foo;
  } );

If a filter function has an empty prototype, it's assumed to work on $_:

  $mason->post_process( sub () {
    s/a-Z/A-Z/
  } );

=head2 Public Methods

=over 4

=item post_processors()

Gets and sets the functions to be used for output filtering.

Called with no arguments, returns the list of filter functions:

  my @functions = $mason->post_processors();

Called with one array-ref argument, sets the list of filter functions:

  $mason->post_processors( \@functions );

Called with one or more function-ref arguments, appends to the list:

  $mason->post_processors( $filter1, $filter2 );

=back

=head2 Supported Attributes

=over 4

=item post_process

Stores a reference to a function or an array of functions to be used:

  $mason->{post_process} = $function;
  $mason->{post_process} = [ $function1, $function2 ];

You can set this attribute when you create your mason object, or in calls to the compile and execute methods. 

=back

=head2 Private Methods

=over 4

=item post_process()

  $mason->post_process( $output ) : $filtered_output

Applies the post-processing filter.

=back


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
