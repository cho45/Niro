package Text::MicroMason::ServerPages;

use strict;
use Carp;

use Safe;

######################################################################

my %block_types = ( 
  ''   => 'perl',	# <% perl statements %>
  '='  => 'expr',	# <%= perl expression %>
  '--' => 'doc',	# <%-- this text will not appear in the output --%>
  '&'  => 'file',	# <%& filename argument %>
);

my $re_eol = "(?:\\r\\n|\\r|\\n|\\z)";
my $re_tag = "perl|args|once|init|cleanup|doc|text|expr|file";

sub lex_token {
  # Blocks in <%word> ... <%word> tags.
  /\G \<\%($re_tag)\> (.*?) \<\/\%\1\> $re_eol? /xcogs ? ( $1 => $2 ) :
  
  # Blocks in <% ... %> tags.
  /\G \<\% (\=|\&)? ( .*? ) \%\> /gcxs ? ( $block_types{$1 || ''} => $2 ) :
  
  # Blocks in <%-- ... --%> tags.
  /\G \<\% \-\- ( .*? ) \-\- \%\> /gcxs ? ( 'doc' => $1 ) :
  
  # Things that don't match the above
  /\G ( (?: [^\<]+ | \<(?!\%) )? ) /gcxs ? ( 'text' => $1 ) :

  # Lexer error
  ()
}

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::ServerPages - Alternate Syntax like ASP/JSP Templates


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason::Base->new( -ServerPages );

Use the standard compile and execute methods to parse and evalute templates:

  print $mason->compile( text=>$template )->( @%args );
  print $mason->execute( text=>$template, @args );

Server Pages syntax provides another way to mix Perl into a text template:

    <% my $name = $ARGS{name};
      if ( $name eq 'Dave' ) {  %>
      I'm sorry <%= $name %>, I'm afraid I can't do that right now.
    <% } else { 
	my $hour = (localtime)[2];
	my $daypart = ( $hour > 11 ) ? 'afternoon' : 'morning'; 
      %>
      Good <%= $daypart %>, <%= $name %>!
    <% } %>


=head1 DESCRIPTION

This subclass replaces MicroMason's normal lexer with one that supports a syntax similar to Active Server Pages and Java Server Pages.

=head2 Compatibility with Apache::ASP

Apache::ASP is a full-featured application server toolkit with many fatures, of which only the templating functionality is emulated.

This is not a drop-in replacement for Apache::ASP, as the implementation is quite different, but it should be able to process some existing templates without major changes.

The following features of EmbPerl syntax are supported:

=over 4

=item *

Angle-bracket markup tags

=back

The following syntax features of are B<not> supported:

=over 4

=item *

Dynamic XML/XSL processing.

=item *

Web server objects such as $Session, $Request, $Response, and $Application.

=item *

Application events such as Application_OnStart, Script_OnStart, and other gloga.asa features.

=back

=head2 Template Syntax

The following elements are recognized by the ServerPages lexer:

=over 4

=item *

E<lt>% perl statements %E<gt>

Arbitrary Perl code to be executed at this point in the template.

=item *

E<lt>%= perl expression %E<gt>

A Perl expression to be evaluated and included in the output.

=item *

E<lt>%& file, arguments %E<gt>

Includes an external template file. 

=item *

E<lt>%-- comment --%E<gt>

Documentation or inactive code to be skipped over silently. Can also be used to quickly comment out part of a template.

=item *

E<lt>%I<name>E<gt> ... E<lt>/%I<name>E<gt>

Supported block names are: 'perl', 'args', 'once', 'init', 'cleanup', and 'doc'.

=back

=head2 Private Methods

=over 4

=item lex_token

  ( $type, $value ) = $mason->lex_token();

Lexer for <% ... %> tags.

Attempts to parse a token from the template text stored in the global $_ and returns a token type and value. Returns an empty list if unable to parse further due to an error.

=back

=cut


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
