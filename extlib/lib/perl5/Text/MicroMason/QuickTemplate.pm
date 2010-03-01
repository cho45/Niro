package Text::MicroMason::QuickTemplate;

require Text::MicroMason::Base;
require Text::MicroMason::StoreOne;
require Text::MicroMason::HasParams;
push @ISA, map "Text::MicroMason::$_", qw( StoreOne HasParams );

require Exporter;
$DONTSET = \"";
sub import { @EXPORT = '$DONTSET'; goto &Exporter::import }

######################################################################

sub defaults {
  (shift)->NEXT('defaults'), delimiters => [ '{{', '}}' ],
}

######################################################################

sub lex_token {
  my $self = shift;
  
  my ($l_delim, $r_delim) = @{ $self->{'delimiters'} };
  /\G \Q$l_delim\E (.*?) \Q$r_delim\E/gcxs ? ( expr => 
      'my @param = $m->param(' . "'\Q$1\E'" . ');
      scalar @param or die "could not resolve the following symbol: ' . $1 . '"; 
      ( $param[0] eq "' . $DONTSET . '" ) ? "{{' . $1 . '}}" : $param[0]' ) :
  
  # Things that don't match the above
  /\G ( (?: [^\{] | \{(?!\{) )+ ) /gcxs ? ( 'text' => $1 ) : 
  
  ()
}

######################################################################

sub fill { (shift)->execute_again( @_ ) }

sub pre_fill { unshift @{ (shift)->{params} }, { @_ } }

sub clear_values { @{ (shift)->{params} } = () }

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::QuickTemplate - Alternate Syntax like Text::QuickTemplate


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

  use Text::MicroMason;
  my $mason = Text::MicroMason::Base->new( -QuickTemplate );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

Or use Text::QuickTemplate's calling conventions:

    $template = Text::MicroMason->new( -HTMLTemplate, text=>'simple.tmpl' );
    print $template->fill( %arguments );

Text::QuickTemplate provides a syntax to embed values into a text template:

    Good {{timeofday}}, {{name}}!


=head1 DESCRIPTION

This mixin class overrides several methods to allow MicroMason to emulate
the template syntax and some of the other features of Text::QuickTemplate.

This class automatically includes the following other mixins: TemplateDir, HasParams, and StoreOne.

=head2 Compatibility with Text::QuickTemplate

This is not a drop-in replacement for Text::QuickTemplate, as the implementation is quite different, but it should be able to process most existing templates without major changes.

The following features of EmbPerl syntax are supported:

=over 4

=item *

Curly bracketed tags with parameter names.

=item *

Array of parameters hashes.

=item *

Special $DONTSET variable.

=back


=head1 SEE ALSO

The interface being emulated is described in L<Text::QuickTemplate>.

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
