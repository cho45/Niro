package Text::MicroMason::Base;

use strict;
require Carp;

######################################################################

######################################################################

use Class::MixinFactory -hasafactory;
for my $factory ( (__PACKAGE__)->mixin_factory ) {
  $factory->base_class( "Text::MicroMason::Base" );
  $factory->mixin_prefix( "Text::MicroMason" );
}

######################################################################

######################################################################

sub new { 
  my $callee = shift;
  my ( @traits, @attribs );
  while ( scalar @_ ) {
    if (  $_[0] =~ /^\-(\w+)$/ ) {
      push @traits, $1;
      shift;
    } else {
      push @attribs, splice(@_, 0, 2);
    }
  }
  if ( scalar @traits ) {
    die("Adding moxins to an existing class not supported yet!") 
	unless ( $callee eq __PACKAGE__ );
    $callee->class( @traits )->create( @attribs ) 
  } else {
    $callee->create( @attribs ) 
  }
}

######################################################################

# $mason = $class->create( %options );
# $clone = $object->create( %options );
sub create {
  my $referent = shift;
  if ( ! ref $referent ) {
    bless { $referent->defaults(), @_ }, $referent;
  } else {
    bless { $referent->defaults(), %$referent, @_ }, ref $referent;
  }
}

sub defaults {
  return ()
}

######################################################################

######################################################################

# $code_ref = $mason->compile( text => $template, %options );
# $code_ref = $mason->compile( file => $filename, %options );
# $code_ref = $mason->compile( handle => $filehandle, %options );
sub compile {
    my ( $self, $src_type, $src_data, %options ) = @_;

    ($self, $src_type, $src_data) = $self->prepare($src_type, $src_data,%options);
    
    my $code = $self->interpret( $src_type, $src_data );
    
    $self->eval_sub( $code ) 
        or $self->croak_msg( "MicroMason compilation failed: $@\n". _number_lines($code)."\n" );

}

# Internal helper to number the lines in the compiled template when compilation croaks
sub _number_lines {
    my $code = shift;

    my $n = 0;
    return join("\n", map { sprintf("%4d  %s", $n++, $_) } split(/\n/, $code)).
        "\n** Please use Text::MicroMason->new\(-LineNumbers\) for better diagnostics!";
}


######################################################################

# $result = $mason->execute( code => $subref, @arguments );
# $result = $mason->execute( $src_type, $src_data, @arguments );
# $result = $mason->execute( $src_type, $src_data, \%options, @arguments );
sub execute {
  my $self = shift;
  my $sub = ( $_[0] eq 'code' ) ? do { shift; shift } : 
	$self->compile( shift, shift, ref($_[0]) ? %{ shift() } : () )
    or $self->croak_msg("MicroMason compilation failed: $@");
  &$sub( @_ );
}

######################################################################

######################################################################

# ($self, $src_type, $src_data) = $self->prepare($src_type, $src_data, %options)
sub prepare {
  my ( $self, $src_type, $src_data, %options ) = @_;
  $self = $self->create( %options ) if ( scalar keys %options );
  return ( $self, $src_type, $src_data );
}

######################################################################

# $perl_code = $mason->interpret( $src_type, $src_data );
sub interpret {
  my ( $self, $src_type, $src_data ) = @_;
  my $template = $self->read( $src_type, $src_data );
  my @tokens = $self->lex( $template );
  my $code = $self->assemble( @tokens );

  # Source file and line number
  my $source_line = $self->source_file_line_label( $src_type, $src_data );
  
  return $source_line . "\n" . $code;
}

# $line_number_comment = $mason->source_file_line_label( $src_type, $src_data );
sub source_file_line_label {
    my ( $self, $src_type, $src_data ) = @_;

    if ( $src_type eq 'file' ) {
        return qq(# line 1 "$src_data");
    }
    
    my @caller; 
    my $call_level;
    do { @caller = caller( ++ $call_level ) }
        while ( $caller[0] =~ /^Text::MicroMason/ or $self->isa($caller[0]) );
    my $package = ( $caller[1] || $0 );
    qq{# line 1 "text template (compiled at $package line $caller[2])"}
}


######################################################################

# $code_ref = $mason->eval_sub( $perl_code );
sub eval_sub {
  my $m = shift;
  package Text::MicroMason::Commands; 
  eval( shift )
}

######################################################################

######################################################################

# $template = $mason->read( $src_type, $src_data );
sub read {
  my ( $self, $src_type, $src_data ) = @_;

  my $src_method = "read_$src_type";
  $self->can($src_method) 
      or $self->croak_msg("Unsupported source type '$src_type'");
  $self->$src_method( $src_data );
}

# $template = $mason->read_text( $template );
sub read_text {
  ref($_[1]) ? $$_[1] : $_[1];
}

# $contents = $mason->read_file( $filename );
sub read_file {
  my ( $self, $file ) = @_;
  local *FILE;
  open FILE, "$file" or $self->croak_msg("MicroMason can't open $file: $!");
  local $/ = undef;
  local $_ = <FILE>;
  close FILE or $self->croak_msg("MicroMason can't close $file: $!");;
  return $_;
}

# $contents = $mason->read_handle( $filehandle );
sub read_handle {
  my ( $self, $handle ) = @_;
  my $fh = (ref $handle eq 'GLOB') ? $handle : $$handle;
  local $/ = undef;
  <$fh>
}

######################################################################

# @token_pairs = $mason->lex( $template );
sub lex {
  my $self = shift;
  local $_ = "$_[0]";
  my @tokens;
  my $lexer = $self->can('lex_token') 
    or $self->croak_msg('Unable to lex_token(); must select a syntax mixin');
  # warn "Lexing: " . pos($_) . " of " . length($_) . "\n";
  until ( /\G\z/gc ) {
    my @parsed = &$lexer( $self ) or      
	/\G ( .{0,20} ) /gcxs 
	  && die "MicroMason parsing halted at '$1'\n";
    push @tokens, @parsed;
  }
  return @tokens;
}

# ( $type, $value ) = $mason->lex_token();
sub lex_token {
  die "The lex_token() method is abstract and must be provided by a subclass";
}

######################################################################

######################################################################

# Text elements used for subroutine assembly
sub assembler_rules {
  template => [ qw( $sub_start $init_errs $init_output
		    $init_args @perl $return_output $sub_end ) ],

  # Subroutine scafolding
  sub_start  => 'sub { ',
  sub_end  => '}',
  init_errs => 
    'local $SIG{__DIE__} = sub { die "MicroMason execution failed: ", @_ };',
  
  # Argument processing elements
  init_args => 'my %ARGS = @_ if ($#_ % 2);',
  
  # Output generation
  init_output => sub { my $m = shift; my $sub = $m->{output_sub} ? '$m->{output_sub}' : 'sub {push @OUT, @_}'; 'my @OUT; my $_out = ' . $sub . ';' },
  add_output => sub { my $m = shift; $m->{output_sub} ? '&$_out' : 'push @OUT,' },
  return_output => 'join("", @OUT)',

  # Mapping between token types
  text_token => 'perl OUT( QUOTED );',
  expr_token => "perl OUT( do{\nTOKEN\n} );", 
  file_token => "perl OUT( \$m->execute( file => do {\nTOKEN\n} ) );",
    # Note that we need newline after TOKEN here in case it ends with a comment.
}

sub assembler_vars {
  my $self = shift;
  my %assembler = $self->assembler_rules();
  
  my @assembly = @{ delete $assembler{ template } };
  
  my %token_map = map { ( /^(.*?)_token$/ )[0] => delete $assembler{$_} } 
					    grep { /_token$/ } keys %assembler;

  my %fragments = map { $_ => map { ref($_) ? &{$_}( $self ) : $_ } $assembler{$_} } keys %assembler;

  return( \@assembly, \%fragments, \%token_map );
}

# $perl_code = $mason->assemble( @tokens );
sub assemble {
  my $self = shift;
  my @tokens = @_;
  
  my ( $order, $fragments, $token_map ) = $self->assembler_vars();
  
  my %token_streams = map { $_ => [] } map { ( /^\W?\@(\w+)$/ ) } @$order;

  while ( scalar @tokens ) {
    my ( $type, $token ) = splice( @tokens, 0, 2 );
    
    unless ( $token_streams{$type} or $token_map->{$type} ) {
      my $method = "assemble_$type";
      my $sub = $self->can( $method ) 
	or $self->croak_msg( "Unexpected token type '$type': '$token'" );
      ($type, $token) = &$sub( $self, $token );
    }
    
    if ( my $typedef = $token_map->{ $type } ) {
      # Perform token map substitution in a single pass so that uses of
      # OUT in the token text are not improperly converted to output calls.
      #   -- Simon, 2009-11-14
      my %substitution_map = (
        'OUT'    => $fragments->{add_output},
        'TOKEN'  => $token,
        'QUOTED' => "qq(\Q$token\E)",
      );
      $typedef =~ s/\b(OUT|TOKEN|QUOTED)\b/$substitution_map{$1}/g;
      
      ( $type, $token ) = split ' ', $typedef, 2;
    }
    
    my $ary = $token_streams{$type}
	or $self->croak_msg( "Unexpected token type '$type': '$token'" );
    
    push @$ary, $token
  }
  
  join( "\n",  map { 
    /^(\W+)(\w+)$/ or $self->croak_msg("Can't assemble $_");
    if ( $1 eq '$' ) {
      $fragments->{ $2 }
    } elsif ( $1 eq '@' ) {
      @{ $token_streams{ $2 } }
    } elsif ( $1 eq '!@' ) {
      reverse @{ $token_streams{ $2 } }
    } elsif ( $1 eq '-@' ) {
      ()
    } else {
      $self->croak_msg("Can't assemble $_");
    }
  } @$order );
}

######################################################################

######################################################################

sub croak_msg {
  local $Carp::CarpLevel = 2;
  shift and Carp::croak( ( @_ == 1 ) ? $_[0] : join(' ', map _printable(), @_) )
}

my %Escape = ( 
  ( map { chr($_), unpack('H2', chr($_)) } (0..255) ),
  "\\"=>'\\', "\r"=>'r', "\n"=>'n', "\t"=>'t', "\""=>'"' 
);

# $special_characters_escaped = _printable( $source_string );
sub _printable {
  local $_ = scalar(@_) ? (shift) : $_;
  return "(undef)" unless defined;
  s/([\r\n\t\"\\\x00-\x1f\x7F-\xFF])/\\$Escape{$1}/sgo;
  /[^\w\d\-\:\.\']/ ? "q($_)" : $_;
}

######################################################################


sub cache_key {
    my $self = shift;
    my ($src_type, $src_data, %options) = @_;

    return $src_data;
}


1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::Base - Abstract Template Compiler 


=head1 SYNOPSIS

Create a MicroMason object to interpret the templates:

    use Text::MicroMason;
    my $mason = Text::MicroMason->new();

Use the execute method to parse and evalute a template:

    print $mason->execute( text=>$template, 'name'=>'Dave' );

Or compile it into a subroutine, and evaluate repeatedly:

    $coderef = $mason->compile( text=>$template );
    print $coderef->('name'=>'Dave');
    print $coderef->('name'=>'Bob');

Templates stored in files can be run directly or included in others:

    print $mason->execute( file=>"./greeting.msn", 'name'=>'Charles');


=head1 DESCRIPTION

Text::MicroMason::Base is an abstract superclass that provides a parser 
and execution environment for an extensible templating system.

=head2 Public Methods

=over 4

=item new()

  $mason = Text::MicroMason::Base->new( -Mixin1, -Mixin2, %attribs );

Creates a new Text::MicroMason object with mixins and attributes. 

Arguments beginning with a dash will be added as mixin classes.
Other arguments are added to the hash of attributes.

=item compile()

  $code_ref = $mason->compile( text => $template, %options );
  $code_ref = $mason->compile( file => $filename, %options );

Parses the provided template and converts it into a new Perl subroutine.

=item execute()

  $result = $mason->execute( text => $template, @arguments );
  $result = $mason->execute( file => $filename, @arguments );
  $result = $mason->execute( code => $code_ref, @arguments );

  $result = $mason->execute( $type => $source, \%options, @arguments );

Returns the results produced by the template, given the provided arguments.

=back

=head2 Attributes

Attributes can be set in a call to new() and locally overridden in a call to compile().

=over 4

=item output_sub

Optional reference to a subroutine to call with each piece of template output. If this is enabled, template subroutines will return an empty string. 

=back

=head2 Private Methods

The following internal methods are used to implement the public interface described above, and may be overridden by subclasses and mixins.

=over 4

=item class()

  $class = Text::MicroMason::Base->class( @Mixins );

Creates a subclass of this package that also inherits from the other classes named. Provided by Class::MixinFactory::HasAFactory. 

=item create()

  $mason = $class->create( %options );
  $clone = $mason->create( %options );

Creates a new instance with the provided key value pairs.

To obtain the functionality of one of the supported mixin classes, use the class method to generate the mixed class before calling create(), as is done by new().

=item defaults()

This class method is called by new() to provide key-value pairs to be included in the new instance.

=item prepare()

  ($self, $src_type, $src_data) = $self->prepare($src_type, $src_data, %options)

Called by compile(), the prepare method allows for single-use attributes and provides a hook for mixin functionality. 

The prepare method provides a hook for mixins to normalize or resolve the template source type and value arguments in various ways before the template is read using one of the read_type() methods. 

It returns an object reference that may be a clone of the original mason object with various compile-time attributes applied. The cloning is a shallow copy performed by the create() method. This means that the $m object visible to a template may not be the same as the MicroMason object on which compile() was originally called.

Please note that this clone-on-prepare behavior is subject to change in future releases.

=item interpret

   $perl_code = $mason->interpret( $src_type, $src_data );

Called by compile(), the interpret method then calls the read(), lex(), and assemble() methods.

=item read

  $template = $mason->read( $src_type, $src_data );

Called by interpret(). Calls one of the below read_* methods.

=item read_text

  $template = $mason->read_text( $template );

Called by read() when the template source type is "text", this method simply returns the value of the text string passed to it. 

=item read_file

  ( $contents, %path_info ) = $mason->read_file( $filename );

Called by read() when the template source type is "file", this method reads and returns the contents of the named file.

=item read_handle

  $template = $mason->read_handle( $filehandle );

Called by read() when the template source type is "handle", this method reads and returns the contents of the filehandle passed to it. 

=item lex

  @token_pairs = $mason->lex( $template );

Called by interpret(). Parses the source text and returns a list of pairs of token types and values. Loops through repeated calls to lex_token().

=item lex_token

  ( $type, $value ) = $mason->lex_token();

Attempts to parse a token from the template text stored in the global $_ and returns a token type and value. Returns an empty list if unable to parse further due to an error.

Abstract method; must be implemented by subclasses. 

=item assemble

  $perl_code = $mason->assemble( @tokens );

Called by interpret(). Assembles the parsed token series into the source code for the equivalent Perl subroutine.

=item assembler_rules()

Returns a hash of text elements used for Perl subroutine assembly. Used by assemble(). 

The assembly template defines the types of blocks supported and the order they appear in, as well as where other standard elements should go. Those other elements also appear in the assembler hash.

=item eval_sub

  $code_ref = $mason->eval_sub( $perl_code );

Called by compile(). Compiles the Perl source code for a template using eval(), and returns a code reference. 

=item croak_msg 

Called when a fatal exception has occurred.

=item NEXT

Enhanced superclass method dispatch for use inside mixin class methods. Allows mixin classes to redispatch to other classes in the inheritance tree without themselves inheriting from anything. Provided by Class::MixinFactory::NEXT. 

=back

=head2 Private Functions

=over 4

=item _printable

  $special_characters_escaped = _printable( $source_string );

Converts non-printable characters to readable form using the standard backslash notation, such as "\n" for newline.

=back

=head1 EXTENDING

You can add functionality to this module by creating subclasses or mixin classes. 

To create a subclass, just inherit from the base class or some dynamically-assembled class. To create your own mixin classes which can be combined with other mixin features, examine the operation of the class() and NEXT() methods.

Key areas for subclass writers are:

=over 4

=item prepare

You can intercept and re-write template source arguments by overriding this method.

=item read_*

You can support a new template source type by creating a method with a corresponding name prefixed by "read_". It is passed the template source value and should return the raw text to be lexed.

For example, if a subclass defined a method named read_from_db, callers could compile templates by calling C<-E<gt>compile( from_db =E<gt> 'welcome-page' )>.

=item lex_token

Replace this to parse a new template syntax. Is receives the text to be parsed in $_ and should match from the current position to return the next token type and its contents.

=item assembler_rules

The assembler data structure is used to construct the Perl subroutine for a parsed template.

=item assemble_*

You can support a new token type be creating a method with a corresponding name prefixed by "assemble_". It is passed the token value or contents, and should return a new token pair that is supported by the assembler template.

For example, if a subclass defined a method named assemble_sqlquery, callers could compile templates that contained a C<E<lt>%sqlqueryE<gt> ... E<lt>/%sqlqueryE<gt>> block. The assemble_sqlquery method could return a C<perl => $statements> pair with Perl code that performed some appropriate action.

=item compile

You can wrap or cache the results of this method, which is the primary public interface. 

=item execute

You typically should not depend on overriding this method because callers can invoke the compiled subroutines directly without calling execute.

=back

=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
