package Text::MicroMason::SafeServerPages;

use strict;

our $VERSION = '0.03';

my %block_types = (
	''     => 'perl', # <% perl statements %>
	'='    => 'expr', # <%= perl expression (HTML escaped) %>
	'raw=' => 'expr', # <%= perl expression (raw) %>
	'--'   => 'doc',  # <%-- this text will not appear in the output --%>
	'&'    => 'file', # <%& filename argument %>
);

my $re_eol = "(?:\\r?\\n|\\r|\\z)";
my $re_tag = "args|cleanup|doc|expr|file|init|once|perl|text";

sub lex_token {
	# Blocks in <%word> ... </%word> tags.
	/\G <% ($re_tag) \s*> (.*?) <\/% \1 \s*> $re_eol? /xcogs ? ( $1 => $2 ) :

	# Blocks in <% ... %> tags.
	/\G <% ((?:(?:raw)?=|&)?) (.*?) %> /gcxs ? ( $block_types{$1} => ($1 eq '=') ? "encode_entities(do { $2 }, '<>&\"\\'')" : $2 ) :

	# Blocks in <%-- ... --%> tags.
	/\G <% -- (.*?) -- %> /gcxs ? ( 'doc' => $1 ) :

	# Things that don't match the above.
	/\G ( (?: [^<] | <(?!\/?%) )+ ) /gcxs ? ( 'text' => $1 ) :

	# Lexer error.
	()
}


sub assemble {
	my ($self, @tokens) = @_;

	my $perl_code = $self->NEXT('assemble', @tokens);

	return "do { use HTML::Entities; $perl_code };";
}


1;
__END__

=head1 NAME

Text::MicroMason::SafeServerPages - Safety ServerPages syntax

=head1 SYNOPSIS

  use Text::MicroMason;
  use Text::MicroMason::SafeServerPages;

  my $m = Text::MicroMason->new(qw/ -SafeServerPages /);

  my $template = <<'EOF';
  <% my $s = \%ARGS; %>
  <html>
  <title><%= $s->{title} %></title>

  <%raw= $s->{body} %>
  </html>
  EOF

  my $cr = $m->compile( text => $template );

  print $cr->(
    title => "Foo<bar>",
    body  => qq{<div class="section">aaaa</div>},
  );


=head1 DESCRIPTION

Text::MicroMason::SafeServerPages is same as L<Text::MicroMason::ServerPages> but HTML-escaped by default.

=head2 Template Syntax

Same as L<Text::MicroMason::ServerPages> but =.

=over

=item * E<lt>%= perl expression %E<gt>

Include evaluated value with HTML-escape.

=item * E<lt>%raw= perl expression %E<gt>

Include evaluated value without HTML-escape.

=back

=head1 AUTHOR

cho45 E<lt>cho45@lowreal.netE<gt>

=head1 SEE ALSO

L<Text::MicroMason>, L<Text::MicroMason::ServerPages>

=head1 LICENSE

Original is Text::MicroMason::ServerPages.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
