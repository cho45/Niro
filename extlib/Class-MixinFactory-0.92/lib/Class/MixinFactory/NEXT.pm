package Class::MixinFactory::NEXT;

use strict;

########################################################################

sub NEXT {
  my ( $self, $method, @args ) = @_;
  
  my $package = caller();
  my @classes = ref($self) || $self;
  
  my $found_current = 0;
  while ( my $class = shift @classes ) {
    if ( $class eq $package ) {
      $found_current = 1
    } elsif ( $found_current and my $sub = $class->can( $method ) ) {
      return &$sub( $self, @args );
    } 
    no strict;
    unshift @classes, @{ $class . "::ISA" };
  }
  Carp::croak( "Can't find NEXT method for $method" );
}

########################################################################

1;

__END__

=head1 NAME

Class::MixinFactory::NEXT - Superclass method redispatch for mixins

=head1 SYNOPSIS

  use Class::MixinFactory::NEXT;

  package My::BaseClass;  
  sub foo { return "Foo Bar" }

  package My::Logging;
  sub foo { warn "Calling foo"; (shift)->NEXT('foo', @_) }

  package My::MixedClass;
  @ISA = ( 'My::Logging', 'My::BaseClass', 'Class::MixinFactory::NEXT'; );

  package main;
  print My::MixedClass->foo();


=head1 DESCRIPTION

Enhanced superclass method dispatch for use inside mixin class methods. Allows mixin classes to redispatch to other classes in the inheritance tree without themselves inheriting from anything. 

=head2 Public Methods

This package defines one method, named NEXT.

  $callee->NEXT( $method, @args );

Searches the inheritance tree of the callee until it finds the package from which NEXT is being called, and then continues searching until the next class which can perform the named method. 

Unlike SUPER, this method will backtrack down the inheritance tree to find implementations later in the search path even if they are on a separate branch.


=head1 SEE ALSO

This class is automatically included by L<Class::MixinFactory>.

This is similar to the functionality provided by NEXT::ACTUAL, but without using AUTOLOAD; for a more generalized approach to this issue see L<NEXT>.

For distribution, installation, support, copyright and license 
information, see L<Class::MixinFactory::ReadMe>.

=cut
