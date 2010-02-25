package Text::MicroMason::Debug;

use strict;
use Carp;

######################################################################

use vars qw( %Defaults );

sub defaults {
  (shift)->NEXT('defaults'), debug => { default => 1 },
}

######################################################################

sub debug_msg {
  my $self = shift;
  my $type = shift;
  my $flag = ( ! ref $self->{debug} )        ? $self->{debug} : 
	     exists( $self->{debug}{$type} ) ? $self->{debug}{$type} : 
					       $self->{debug}{'default'};
  if ( $flag ) {
    warn "MicroMason Debug $type: " . ( ( @_ == 1 ) ? $_[0] : join( ', ', map Text::MicroMason::Base::_printable(), @_ ) ) . "\n";
  }

  wantarray ? @_ : $_[0];
}

######################################################################

sub new {
  my $self = shift;
  $self->debug_msg( 'new', $self, @_ );
  $self->NEXT( 'new', @_ );
}

sub create {
  my $self = (shift)->NEXT( 'create', @_ );
  $self->debug_msg( 'create', ref($self), %$self );
  return $self;
}

sub prepare {
  my ( $self, $src_type, $src_data ) = @_;
  my @result = $self->NEXT( 'prepare', $src_type, $src_data );
  if ( scalar @result > 3 or grep { $result[$_] ne $_[$_] } 0 .. 2 ){
    $self->debug_msg( 'prepare', @result );
  } 
  return @result;
}

sub interpret {
  my $self = shift;
  $self->debug_msg( 'interpret', @_ );
  $self->NEXT( 'interpret', @_ )
}

# $contents = $mason->read_file( $filename );
sub read_file {
  my $self = shift;
  $self->debug_msg( 'read', "Opening file '$_[0]'" );
  $self->NEXT( 'read_file', @_ )
}

sub lex {
  my $self = shift;
  $self->debug_msg( 'source', @_ );
  $self->debug_msg( 'lex', $self->NEXT( 'lex', @_ ) );
}

sub assemble {
  my $self = shift;
  $self->debug_msg( 'assemble', $self->NEXT( 'assemble', @_ ) );
}

sub eval_sub {
  my $self = shift;
  $self->debug_msg( 'eval', @_ );
  $self->NEXT( 'eval_sub', @_ )
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::Debug - Provide developer info via warn


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

  use Text::MicroMason;
  my $mason = Text::MicroMason->new( -Debug );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

You'll see lots of warning output on STDERR:

  MicroMason Debug create: Text::MicroMason::Base::AUTO::Debug...
  MicroMason Debug source: q(Hello <% $noun %>!)
  MicroMason Debug lex: text, q(Hello ), expr, q( $noun ), text, q(!)
  MicroMason Debug eval: sub { my @OUT; my $_out = sub { push ...

=head1 DESCRIPTION

This package provides numerous messages via warn for developer use when debugging templates built with Text::MicroMason.

=head2 Supported Attributes

=over 4

=item debug

Activates debugging messages for many methods. Defaults to logging everything.

Can be set to 0 or 1 to log nothing or everything.

Alternately, set this to a hash reference containing values for the steps you are interested in to only log this items:

  debug => { source => 1, eval => 1 }

You can also selectively surpress some warnings:

  debug => { default => 1, source => 0, eval => 0 }

=back

=head2 Private Methods

=over 4

=item debug_msg

Called to provide a debugging message for developer reference. No output is produced unless the object's 'debug' flag is true.

=back


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
