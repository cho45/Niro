package Text::MicroMason::HTMLTemplate;

require Text::MicroMason::Base;
require Text::MicroMason::TemplateDir;
require Text::MicroMason::StoreOne;
require Text::MicroMason::HasParams;
push @ISA, map "Text::MicroMason::$_", qw( TemplateDir StoreOne HasParams );

use strict;

######################################################################

my %param_mapping = (    		### <<== INCOMPLETE ###
  global_vars => 'loop_global_vars',
  cache => '-CompileCache',
  path => '-TemplatePaths',
);

######################################################################

sub output { (shift)->execute_again( @_ ) }

######################################################################

my $prefix_re = '[tT][mM][pP][lL]_';

sub lex_token {
  # warn " Lexer: " . pos($_) . " of " . length($_) . "\n";
  # Tags in format "<TMPL_FOO>", "<TMPL_FOO NAME=VAR>", or "</TMPL_FOO>"
  /\G \<(\/?)($prefix_re\w+)\s*(.*?)\> /gcxs 
	? ( ( $1 ? "tmpl_end" : lc($2) ) => { $_[0]->parse_args($3) } ) :
  
  # Things that don't match the above
  /\G ( (?: [^<] | <(?!\/?$prefix_re) )+ ) /gcxs ? ( 'text' => $1 ) : 

  # Lexer error
  ()
}

sub parse_args {
  my $self = shift;
  my $args = "$_[0]";
  return () unless length($args);
  return ( name => $args ) unless ( $args =~ /=/ );
  my @tokens;
  until ( $args =~ /\G\z/gc ) {
    push ( @tokens, 
      $args =~ /\G \s* (\w+) \= (?: \"([^\"]+)\" | ( \w+ ) ) (?= \s | \z ) /gcxs
	? ( lc($1) => ( defined($2) ? $2 : $3 ) ) : 
      $args =~ /\G ( .{0,20} ) /gcxs 
	&& die "Couldn't find applicable parsing rule at '$1'\n"
    );
  }
  @tokens;
}

######################################################################

sub assemble_tmpl_var {
  my ($self, $args) = @_;

  my $output = "\$m->param( '$args->{name}' )";
  if ( defined $args->{default} ) {
    $output = "local \$_ = $output; defined ? \$_ : '$args->{default}'"
  }
  if ( $args->{escape} ) {
    $output = "\$m->filter( $output, '$args->{escape}' )"
  }
  expr => "$output;"
}

sub assemble_tmpl_include {
  my ($self, $args) = @_;
  file => $args->{name}
}

sub assemble_tmpl_loop {
  my ($self, $args) = @_;
  if ( ! $self->{loop_context_vars} ) {
    perl => q/foreach my $args ( $m->param( '/ . $args->{name} . q/' ) ) {
      local $m->{params} = [ $args, $m->{loop_global_vars} ? @{$m->{params}} : () ];/
  } else {
    perl => q/my @loop = $m->param( '/ . $args->{name} . q/' );
      foreach my $count ( 0 .. $#loop ) {
    my $args = $loop[ $count ];
    my %loop_context = (
      __counter__ => $count,
      __odd__ => ( $count % 2 ),
      __first__ => ( $count == 0 ),
      __inner__ => ( $count > 0 and $count < $#loop ),
      __last__ => ( $count == $#loop ),
    );
    local $m->{params} = [ $args, \%loop_context, $m->{loop_global_vars} ? @{$m->{params}} : () ];
      /
  }
}

sub assemble_tmpl_if {
  my ($self, $args) = @_;
  perl => q/if ( $m->param( '/ . $args->{name} . q/' ) ) { /
}

sub assemble_tmpl_unless {
  my ($self, $args) = @_;
  perl => q/if ( ! $m->param( '/ . $args->{name} . q/' ) ) { /
}

sub assemble_tmpl_else {
  perl => "} else {"
}

sub assemble_tmpl_end {
  perl => "}"
}

######################################################################

use vars qw( %Filters );

sub defaults {
  (shift)->NEXT('defaults'), filters => \%Filters,
}

# Output filtering
$Filters{1} = $Filters{html} = \&HTML::Entities::encode 
					if eval { require HTML::Entities};
$Filters{url} = \&URI::Escape::uri_escape if eval { require URI::Escape };

# $result = $mason->filter( @filters, $content );
sub filter {
  my $self = shift;
  my $content = pop;
  
  foreach my $filter ( @_ ) {
    my $function = ( ref $filter eq 'CODE' ) ? $filter : 
	$self->{filters}{ $filter } || 
	  $self->croak_msg("No definition for a filter named '$filter'" );
    $content = &$function($content)
  }
  $content
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::HTMLTemplate - Alternate Syntax like HTML::Template


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

  use Text::MicroMason;
  my $mason = Text::MicroMason::Base->new( -HTMLTemplate );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

Or use HTML::Template's calling conventions:

    $template = Text::MicroMason->new( -HTMLTemplate, filename=>'simple.tmpl' );
    $template->param( %arguments );
    print $template->output();

HTML::Template provides a syntax to embed values into a text template:

    <TMPL_IF NAME="user_is_dave">
      I'm sorry <TMPLVAR NAME="name">, I'm afraid I can't do that right now.
    <TMPL_ELSE>
      <TMPL_IF NAME="daytime_is_morning">
	Good morning, <TMPLVAR NAME="name">!
      <TMPL_ELSE>
	Good afternoon, <TMPLVAR NAME="name">!
      </TMPL_IF>
    </TMPL_IF>


=head1 DESCRIPTION

This mixin class overrides several methods to allow MicroMason to emulate
the template syntax and some of the other features of HTML::Template.

This class automatically includes the following other mixins: TemplateDir, HasParams, and StoreOne.

=head2 Compatibility with HTML::Template

This is not a drop-in replacement for HTML::Template, as the implementation is quite different, but it should be able to process most existing templates without major changes.

This should allow current HTML::Template users to take advantage of
MicroMason's one-time compilation feature, which in theory could be faster 
than HTML::Template's run-time interpretation. (No benchmarking yet.)

The following features of HTML::Template are not supported yet:

=over 4

=item *

Search path for files. (Candidate for separate mixin class or addition to TemplateDir.)

=item *

Many HTML::Template options are either unsupported or have different names and need to be mapped to equivalent sets of attributes. (Transform these in the new() method or croak if they're unsupported.)

=back

The following features of HTML::Template will likely never be supported due to fundamental differences in implementation:

=over 4

=item *

query() method

=back

Contributed patches to more closely support the behavior of HTML::Template 
would be welcomed by the author.

=head2 Template Syntax

The following elements are recognized by the HTMLTemplate lexer:

=over 4

=item *

I<literal_text>

Anything not specifically parsed by the below rule is interpreted as literal text.

=item *

E<lt>TMPL_I<tagname>E<gt>

A template tag with no attributes.

=item *

E<lt>TMPL_I<tagname> I<varname>E<gt>

A template tag with a name attribute.

=item *

E<lt>TMPL_I<tagname> NAME=I<varname> I<option>=I<value> ...E<gt>

A template tag with one or more attributes.

=item *

E<lt>/TMPL_I<tagname>E<gt>

A closing template tag.

=back

The following tags are supported by the HTMLTemplate assembler:

=over 4

=item tmpl_var

E<lt>tmpl_var name=... ( default=... ) ( escape=... ) E<gt>

=item tmpl_include

E<lt>tmpl_include name=... E<gt>

=item tmpl_if

E<lt>tmpl_if name=... E<gt> ... E<lt>/tmpl_ifE<gt>

=item tmpl_unless

E<lt>tmpl_unless name=...E<gt> ... E<lt>/tmpl_unlessE<gt>

=item tmpl_else

E<lt>tmpl_elseE<gt>

=item tmpl_loop

E<lt>tmpl_loop name=...E<gt> ... E<lt>/tmpl_loopE<gt>

=back

=head2 Supported Attributes

=over 4

=item associate

Optional reference to a CGI parameter object or other object with a similar param() method. 

=item loop_global_vars (HTML::Template's "global_vars")

If set to true, don't hide external parameters inside a loop scope.

=item loop_context_vars

If set to true, defines additional variables within each <TMPL_LOOP>: __counter__, which specifies the row index, and four boolean flags, __odd__, __first__, __inner__, and __last__.

=back

=head2 Public Methods

=over 4

=item new()

Creates a new Mason object. If a filename parameter is supplied, the corresponding file is compiled.

=item param()

Gets and sets parameter arguments. Similar to the param() method provied by HTML::Template and the CGI module.

=item output()

Executes the most-recently compiled template and returns the results.

Optionally accepts a filehandle to print the results to.

  $template->output( print_to => *STDOUT );

=back

=head2 Private Methods

=over 4

=item lex_token

  ( $type, $value ) = $mason->lex_token();

Lexer for <TMPL_x> tags.

Attempts to parse a token from the template text stored in the global $_ and returns a token type and value. Returns an empty list if unable to parse further due to an error.

=item parse_args()

Lexer for arguments within a tag.

=item assemble_tmpl_*()

These methods define the mapping from the template tags to the equivalent Perl code.

=item filter()

Used to implement the escape option for tmpl_var.

=back


=head1 SEE ALSO

The interface being emulated is described in L<HTML::Template>.

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

