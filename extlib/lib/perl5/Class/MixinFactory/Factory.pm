package Class::MixinFactory::Factory;

$VERSION = 0.91;

########################################################################

use strict;
use Carp ();

########################################################################

use Class::MixinFactory::InsideOutAttr qw(base_class mixin_prefix mixed_prefix);

use Class::MixinFactory::NEXT;
sub next_dispatch_class { 'Class::MixinFactory::NEXT' }

########################################################################

sub new { 
  my $sym;
  my $self = bless \$sym, shift;
  while ( my $method = shift @_ ) {
    $self->$method( shift );
  }
  $self;
}

########################################################################

sub class {
  my $factory = shift;
  my @mixins = ( @_ == 1 and ref($_[0]) ) ? @{ $_[0] } : @_;
  
  my $base_class = $factory->base_class();
  my $mixin_prefix = $factory->mixin_prefix() || $base_class || '';
  my $mixed_prefix = $factory->mixed_prefix() || ( $base_class ? $base_class : ref($factory) || $factory ) . "::AUTO";

  my @classes = map { ( $_ =~ /::/ ) ? $_ : $mixin_prefix ? $mixin_prefix . '::' . $_ : $_ } @mixins;

  my $label = join '_', map { s/^\Q$mixin_prefix\E:://; s/:://g; $_ } map "$_", @classes;
  
  my $new_class = $mixed_prefix . "::" . ( $label || "Base" );
  
  return $new_class if do { no strict 'refs'; @{ "$new_class\::ISA" } };
  
  my @isa = ( @classes, $base_class, $factory->next_dispatch_class );
  
  foreach my $package ( @classes ) {
    next if do { no strict 'refs'; scalar keys %{ $package . '::' } };
    my $filename = "$package.pm";
    $filename =~ s{::}{/}g;
    # warn "require $filename";
    require $filename;
  }

  { no strict; @{ "$new_class\::ISA" } = @isa; }
  
  $new_class;
}

########################################################################

1;

__END__

=head1 NAME

Class::MixinFactory::Factory - Class Factory with Selection of Mixins

=head1 SYNOPSIS

  use Class::MixinFactory::Factory;

  my $factory = Class::MixinFactory::Factory->new();
  
  $factory->base_class( "MyClass");

  $factory->mixin_prefix( "MyMixins" );
  $factory->mixed_prefix( "MyClasses" );

  my $class = $factory->class( @mixins );

=head1 DESCRIPTION

A mixin factory generates new classes at run-time which inherit from each of several classes.

=head1 PUBLIC METHODS

=over 4

=item new()

  $factory_class->new() : $factory
  $factory_class->new( %attributes ) : $factory

Create a new factory object. 

May be passed a hash of attributes, with the key matching one of the supported accessor methods named below and the value containing the value to assign.

=item base_class()

  $factory->base_class() : $package_name
  $factory->base_class( $package_name )

Required. Get or set the base class to be inherited from by all mixed classes.

=item mixin_prefix()

  $factory->mixin_prefix() : $package_name
  $factory->mixin_prefix( $package_name )

Optional. Get or set a prefix to be placed before all mixin class names that don't contain a double-colon. Defaults to the name of the base class. 

=item mixed_prefix()

  $factory->mixed_prefix() : $package_name
  $factory->mixed_prefix( $package_name )

Optional. Get or set a prefix to be placed before all generated class names. Defaults to the name of the base class or the factory class followed by "::AUTO"

=item class()

  $factory->class( @mixins ) : $package_name

Find or generate a class combining the requested mixin classes.

=back


=head1 SEE ALSO

For a facade interface that facilitates access to this functionality, see L<Class::MixinFactory>.

For distribution, installation, support, copyright and license 
information, see L<Class::MixinFactory::ReadMe>.

=cut
