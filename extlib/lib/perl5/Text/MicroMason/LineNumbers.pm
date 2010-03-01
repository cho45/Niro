package Text::MicroMason::LineNumbers;
use strict;

######################################################################

sub read {
  my ( $self, $src_type, $src_data ) = @_;

  $self->{ last_read_file } = "unrecognized source $src_type";
  $self->{ last_read_line } = 1;

  $self->NEXT( 'read', $src_type, $src_data )
}

sub read_file {
  my ( $self, $file ) = @_;

  $self->{ last_read_file } = $file;

  $self->NEXT( 'read_file', $file )
}

sub read_handle {
  my ( $self, $handle ) = @_;

  my ( $caller_file, $caller_line ) = $self->_get_external_caller();
  $self->{ last_read_file } = "file handle template (compiled at $caller_file line $caller_line)";

  $self->NEXT( 'read_handle', $handle )
}

sub read_text {
  my ( $self, $text ) = @_;

  my ( $caller_file, $caller_line ) = $self->_get_external_caller();
  $self->{ last_read_file } = "text template (compiled at $caller_file line $caller_line)";

  $self->NEXT( 'read_text', $text )
}

sub read_inline {
  my ( $self, $text ) = @_;

  my ( $caller_file, $caller_line ) = $self->_get_external_caller();
  $self->{ last_read_file } = $caller_file;
  $self->{ last_read_line } = $caller_line;

  $self->NEXT( 'read_text', $text )
}

sub _get_external_caller {
	my ( $self ) = @_;
  my ( @caller, $call_level );
  do { @caller = caller( ++ $call_level ) }
      while ( $caller[0] =~ /^Text::MicroMason/ or $self->isa($caller[0]) );
  return ( $caller[1] || $0, $caller[2] );
}

######################################################################

sub lex {
    my $self = shift;
    local $_ = "$_[0]";
    
    my $lexer = $self->can('lex_token') 
        or $self->croak_msg('Unable to lex_token(); must select a syntax mixin');
    
    my $filename = $self->{ last_read_file } || 'unknown source';
    my $linenum = $self->{ last_read_line } || 1;
    my $last_pos = 0;
    
    my @tokens;
    until ( /\G\z/gc ) {
        my @parsed = &$lexer( $self )
            or /\G ( .{0,20} ) /gcxs && die "MicroMason parsing halted at '$1'\n";
        push @tokens, 'line_num' => ( $linenum - 1 ) . qq{ "$filename"};
        push @tokens, @parsed;
        
        # Update the current line number by counting newlines in the text 
        # we've parsed since the last time through the loop.
        my $new_pos = pos($_) || 0;
        $linenum += ( substr($_, $last_pos, $new_pos - $last_pos) =~ tr[\n][] ); 
        $last_pos = $new_pos;
    }
    
    return @tokens;
}

sub assembler_rules {
  my $self = shift;
  (
	  $self->NEXT('assembler_rules', @_),
	  line_num_token => 'perl # line TOKEN',
	)
}

######################################################################

1;

######################################################################


=head1 NAME

Text::MicroMason::LineNumbers - Report errors at correct source code line numbers


=head1 DESCRIPTION

This mixin class associates each token in a template with the line
number on which it was found, and then inserts special comments in the
generated Perl code that preserve that original source file and line
number information.

This should facilitate debugging, by making it easier to match up run-
time errors with the template code that produced them.

To turn this behavior on, just add "-LineNumbers" to your MicroMason
creation call:

  my $mason = Text::MicroMason->new( qw( -LineNumbers ) );


=head2 Public Methods

These methods are called from within the normal flow of MicroMason
functionality, and you do not need to invoke them directly.

=over 4

=item read()

Clears the variables used to store the file name and first line of a
template, so that they can be set by the methods below.

=item read_file()

Saves the source file name before invoking the standard behavior for this method.

  $mason->compile( file => $filename );

=item read_handle()

Saves the caller's file name before invoking the standard behavior for this method.

  $mason->compile( handle => $filename );

=item read_text()

Saves the caller's file name before invoking the standard behavior for this method.

  $mason->compile( text => $filename );

=item read_inline()

This is similar to read_text, except it adjusts the line numbering to
reflect a template that's embdded as a literal text in the Perl code.

  $mason->compile( inline => q{
	  My template text goes here.
  } );

=item lex()

Identical to the lex() method provided by the Base class, except that it
also inserts a stream of line-number-setting comments into the to-be-
compiled Perl code that attempt to re-synchronize the

=item assembler_rules()

Maps the "line_num" token to a perl line number comment.

=back


=head2 Private Methods

=over 4

=item _get_external_caller()

Returns the source file and line number of the first item in the
function call stack that is not a Text::MicroMason package.

=back


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut

