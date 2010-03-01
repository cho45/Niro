package Text::MicroMason::ApacheHandler;

use Apache::Constants;
use Apache::Request;

use Text::MicroMason::Base;

######################################################################

my %configs;

sub handler ($$) {
  my ($package, $r) = @_;

  my $apache = Apache::Request->instance( $r );
  
  my $file = $apache->filename;
  
  # $apache->document_root;
  my $syntax = $apache->dir_config('MicroMasonSyntax') || 'HTMLMason';
  my @mixins = $apache->dir_config->get('MicroMasonMixins');
  my @attrs = $apache->dir_config->get('MicroMasonAttribs');

  my %seen;
  unshift @attrs, ( map "-$_", grep { ! $seen{$_} ++ } ( @mixins, $syntax ) );

  my $config = join ' ', @attrs;

  my $mason = ( $configs{$config} ||= Text::MicroMason::Base->new( @attrs ) );
  
  my $template = $mason->compile( file => $file );
  
  $apache->content_type( 'text/html' );
  # $apache->header_out();
  
  local $Text::MicroMason::Commands::r = $apache;
  print $template->( $apache->param() );
  
  return Apache::Constants::OK();
}

sub configure {
  my $apache = Apache::Request->instance( shift );
  
  my $file = $apache->filename;
  
  # $apache->document_root;
  my $syntax = $apache->dir_config('MicroMasonSyntax') || 'HTMLMason';
  my @mixins = $apache->dir_config->get('MicroMasonMixins');
  my @attrs = $apache->dir_config->get('MicroMasonAttribs');

  my %seen;
  unshift @attrs, ( map "-$_", grep { ! $seen{$_} ++ } ( @mixins, $syntax ) );

  my $config = join ' ', @attrs;

  my $mason = ( $configs{$config} ||= Text::MicroMason::Base->new( @attrs ) );
}

######################################################################

sub translate_params {
  MasonAllowGlobals => [ -AllowGlobals, allow_globals => \$1 ],
  MasonCompRoot => [ -TemplateDir, template_root => \$1 ],
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::ApacheHandler - Use MicroMason from mod_perl


=head1 SYNOPSIS

In your httpd.conf or equivalent Apache configuration file:

  PerlModule Text::MicroMason::ApacheHandler

  <Files *.mm>
    SetHandler perl-script
    PerlHandler Text::MicroMason::ApacheHandler
  </Files>

In your document root or other web-accessible directory:

  <% my $visitor = $r->connection->remote_host(); %>
  <html>
    Hello there <%= $visitor %>! 
    The time is now <%= localtime() %>.
  </html>

=head1 DESCRIPTION

B<Caution:> This module is new, experimental, and incomplete. Not intended for production use. Interface subject to change. If you're interested in this capability, your feedback would be appreciated.

=head2 Configuration

The following configuration parameters are supported:

=over 4

=item MicroMasonSyntax

    PerlSetVar MicroMasonSyntax HTMLMason

Name of the syntax class that will compile the templates. Defaults to HTMLMason.

=item MicroMasonMixins

    PerlAddVar MicroMasonMixins Safe
    PerlAddVar MicroMasonMixins CatchErrors

List of additional mixin classes to be enabled.

=item MicroMasonAttribs

    PerlAddVar MicroMasonAttribs "-AllowGlobals, allow_globals => '$r'"

Allows for any set of attributes to be defined. Mixin names prefaced with a dash can also be included.

=back

=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
