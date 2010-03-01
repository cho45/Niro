package Text::MicroMason::ParseInfo;

use strict;
use Carp;

######################################################################

# Each time we compile a new template, make sure we create a private clone of 
# the MicroMason object and store some local information in a "parse_info" hash.

# ($self, $src_type, $src_data) = $self->prepare($src_type, $src_data, %options)
sub prepare {
  my $self = shift;
  $self->NEXT('prepare', @_, parse_info => {})
}

######################################################################

# When compiling a template, we first lex() the source code into tokens, then
# we assemble() it into a Perl subroutine. Mixins can hook into this sequence
# to fiddle around with the template while it's still in a "chunked" format.
# In this case we just store information about tokens in our private hash.

# $perl_code = $mason->assemble( @tokens );
sub assemble {
  my $self = shift;
  my @tokens = @_;

  my $parse_info = ( $self->{parse_info} ||= {} ); 

  for ( my $position = 0; $position <= $#tokens; $position += 2 ) {
    my ( $token_type, $token_value ) = @tokens[$position, $position + 1];

    if ( $token_type eq 'args' ) {
      while ( $token_value =~ /^\s*([\$\@\%])(\w+)(?:\s*=>\s*([^\r\n]+))?/g ) {
	push $parse_info->{'args'}->{ "$1$2" } = $3
      }

    } elsif ( $token_type eq 'file' ) {
      push @{ $parse_info->{'file'} }, $token_value;

    } elsif ( $token_type eq 'doc' ) {
      push @{ $parse_info->{'doc'} }, $token_value;
    }
  }
  
  $self->NEXT('assemble', @tokens );
}

######################################################################

1;

######################################################################

