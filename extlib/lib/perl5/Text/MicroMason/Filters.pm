package Text::MicroMason::Filters;

use strict;
use Carp;

use Safe;

######################################################################

# Output filtering
use vars qw( %Filters );
$Filters{p} = \&Text::MicroMason::Base::_printable;

$Filters{h} = eval { 
      require HTML::Entities; sub { HTML::Entities::encode( $_[0], q[<>&'"] ) } 
    } || eval { require CGI; \&CGI::escapeHTML };

$Filters{u} = eval { require URI::Escape; \&URI::Escape::uri_escape };

sub defaults {
  (shift)->NEXT('defaults'), filters => \%Filters, default_filters => ''
}

######################################################################

# $perl_code = $mason->assemble( @tokens );
sub assemble {
    my $self = shift;
    my @tokens = @_;
    # warn "Filter assemble";
    foreach my $position ( 0 .. int( $#tokens / 2 ) ) {
        if ( $tokens[$position * 2] eq 'expr' ) {
            my $token = $tokens[$position * 2 + 1];
            my $filt_flags = ($token =~ s/(?<!\|)\| # starts with a pipe preceded by not-a-pipe
                                          \s*       # optional white space
                                          (\w+(?:[\s\,]+\w+)*) # \w+ optionally delimited by spaces andor commas
                                          \s*\z     # optional whitespace and the end of string
                                         //x) ? $1 : '';
            
            if (my @filters = $self->parse_filters($self->{default_filters}, $filt_flags)) {
                $token = '$m->filter( ' . join(', ', map "'$_'", @filters ) . ', ' . 
                    'join "", do { ' . $token . '} )';
            }
            $tokens[$position * 2 + 1] = $token;
        }
    }
    $self->NEXT('assemble', @tokens );
}

# @flags = $mason->parse_filters( @filter_strings );
sub parse_filters {
  my $self = shift;
  
  my $no_ns;
  my $short = join '', 'n', grep { length($_) == 1 } keys %{ $self->{filters} };
  reverse grep { not $no_ns ||= /^n$/ } reverse
    map { /^[$short]{2,5}$/ ? split('') : split(/[\s\,]+/) } @_;
}

######################################################################

# %functions = $mason->filter_functions();
# $function  = $mason->filter_functions( $flag );
# @functions = $mason->filter_functions( \@flags );
# $mason->filter_functions( $flag => $function, ... );
sub filter_functions {
  my $self = shift;
  my $filters = ( ref $self ) ? $self->{filters} : \%Filters;
  if ( scalar @_ == 0 ) {
    %$filters
  } elsif ( scalar @_ == 1 ) {
    my $key = shift;
    if ( ! ref $key ) {
      $filters->{ $key }
    } else {
      @{ $filters }{ @$key }
    }
  } else {
    %$filters = ( %$filters, @_ );
  }
}

# @functions = $mason->get_filter_functions( @flags_or_functions );
sub get_filter_functions {
  my $self = shift;
  
  map {
    ( ref $_ eq 'CODE' ) ? $_ : $self->{filters}{ $_ }  
	or $self->croak_msg("No definition for a filter named '$_'" );
  } @_ 
}

# $result = $mason->filter( @filters, $content );
sub filter {
  my $self = shift;
  local $_ = pop;
  
  foreach my $function ( $self->get_filter_functions( @_ ) ) {
    $_ = &$function($_)
  }
  $_
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::Filters - Add Output Filters like "|h" and "|u"


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason->new( -Filters );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

Enables filtering of template expressions using HTML::Mason's conventions:

    <%args> $name </%args>
    Welcome, <% $name |h %>! 
    <a href="more.masn?name=<% $name |u %>">Click for More</a>

You can set a default filter and override it with the "n" flag:

    my $mason = Text::MicroMason->new( -Filters, default_filters => 'h' );

    <%args> $name </%args>
    Welcome, <% $name %>! 
    <a href="more.masn?name=<% $name |nu %>">Click for More</a>

You can define additional filters and stack them:

    my $mason = Text::MicroMason->new( -Filters );
    $mason->filter_functions( myfilter => \&function );
    $mason->filter_functions( uc => sub { return uc( shift ) } );

    <%args> $name </%args>
    Welcome, <% $name |uc,myfilter %>! 


=head1 DESCRIPTION

This module enables the filtering of expressions before they are output, using HTML::Mason's "|hun" syntax.

If you have HTML::Entities and URI::Escape available they are loaded to provide the default "h" and "u" filters. If those modules can not be loaded, no error message is produced but any subsequent use of them will fail.

Attempted use of an unknown filter name will croak with a message stating "No definition for a filter named 'h'".

=head2 Public Methods

=over 4 

=item filter_functions

Gets and sets values from the hash mapping filter flags to functions.

If called with no arguments, returns a hash of all available filter flags and functions:

  %functions = $mason->filter_functions();

If called with a filter flag returns the associated function, or if provided with a reference to an array of flag names returns a list of the functions:

  $function  = $mason->filter_functions( $flag );
  @functions = $mason->filter_functions( \@flags );

If called with one or more pairs of filter flags and associated functions, adds them to the hash. (Any filter that might have existed with the same flag name is overwritten.)

  $mason->filter_functions( $flag => $function, ... );

=back

=head2 Supported Attributes

=over 4

=item default_filters

Optional comma-separated string of filter flags to be applied to all output expressions unless overridden by the "n" flag.

=back

=head2 Private Methods

=over 4

=item assemble()

This method goes through the lexed template tokens looking for uses of filter flags, which it then rewrites as appropriate method calls before passing the tokens on to the superclass.

=item parse_filters

Parses one or more strings containing any number of filter flags and returns a list of flags to be used. 

  @flags = $mason->parse_filters( @filter_strings );

Flags should be separated by commas, except that the commas may be omitted when using a combination of single-letter flags. Flags are applied from left to right. Any use of the "n" flag wipes out all flags defined to the left of it. 

=item get_filter_functions

Accepts filter flags or function references and returns a list of the corresponding functions. Dies if an unknown filter flag is used.

  @functions = $mason->get_filter_functions( @flags_or_functions );

=item filter

Applies one or more filters to the provided content string.

  $result = $mason->filter( @flags_or_functions, $content );

=back


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::HTMLMason>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

