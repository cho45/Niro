package Class::MixinFactory;

$VERSION = 0.92;

use strict;

########################################################################

use Class::MixinFactory::Factory;
sub base_factory_class { 'Class::MixinFactory::Factory' }

use Class::MixinFactory::HasAFactory;
sub hasa_factory_class { 'Class::MixinFactory::HasAFactory' }

########################################################################

sub import {
  my ( $facade, $import, @args ) = @_;

  return unless $import;
  my $target_class = ( caller )[0];

  no strict 'refs';

  if ( $import eq '-isafactory' ) {
    push @{"$target_class\::ISA"}, $facade->base_factory_class;

  } elsif ( $import eq '-hasafactory' ) {
    push @{"$target_class\::ISA"}, $facade->hasa_factory_class();

  } elsif ( $import eq '-isasubclass' ) {
    push @{"$target_class\::ISA"}, (shift @args)->class( @args );
  
  } else {
    require Exporter;
    goto &Exporter::import
  }
}

########################################################################

sub new {
  (shift)->base_factory_class->new( @_ )
}

########################################################################

1;

__END__

=head1 NAME

Class::MixinFactory - Class Factory with Selection of Mixins

=head1 SYNOPSIS

  package MyClass;
  use Class::MixinFactory -hasafactory;
  sub new { ... }
  sub foo { return "Foo Bar" }

  package MyClass::Logging;
  sub foo { warn "Calling foo"; (shift)->NEXT('foo', @_) }

  package MyClass::UpperCase;
  sub foo { uc( (shift)->NEXT('foo', @_) ) }

  package main;

  my $class = MyClass->class( 'Logging', 'UpperCase' );
  print $class->new()->foo(); 
  # Calls MyClass::Logging::foo, MyClass::UpperCase::foo, MyClass::foo


=head1 DESCRIPTION

This distribution facilitates the run-time generation of classes which inherit from a base class and some optional selection of mixin classes. 

A factory is provided to generate the mixed classes with multiple inheritance. 
A NEXT method allows method redispatch up the inheritance chain.

=head1 USAGE

The Class::MixinFactory package is just a facade that loads the necessary classes and provides a few import options for compile-time convenience.

=head2 Factory Interface

To generate an object with some combination of mixins, you first pass the names of the mixin classes to a class factory which will generate a mixed class. (Or return the name of the already generated class, if there has been a previous request with the same combination of mixins.) 

You can add a factory method to your base class, create a separate factory object, or inherit to produce a factory class.

=over 4

=item Factory Method

To add a factory method to a base class, inherit from the Class::MixinFactory::HasAFactory class, or use the C<-hasafactory> import option:

  package MyClass;
  use Class::MixinFactory -hasafactory;

  package main;
  my $class = MyClass->class( 'Logging', 'UpperCase' );
  print $class->new()->foo(); 

=item Factory Class

To create a new class which will act as a factory for another base class, inherit from the Class::MixinFactory::Factory class, or use the C<-isafactory> import option:

  package MyClass::Factory;
  use Class::MixinFactory -isafactory;
  MyClass::Factory->base_class( "MyClass" );

  package main;
  my $class = MyClass::Factory->class( 'Logging', 'UpperCase' );
  print $class->new()->foo();

=item Factory Object

To create an object which will act as a factory, create a Class::MixinFactory::Factory instance by calling the new() method:

  use Class::MixinFactory;
  my $factory = Class::MixinFactory->new();
  $factory->base_class( "MyClass" );

  my $class = $factory->class( 'Logging', 'UpperCase' );
  print $class->new()->foo();

=back

=head2 Inheriting from a Mixed Class

=over 4

=item Inheriting with a Factory Method or Factory Object

A subclass can inherit from a mixed class:

  package MyClass::CustomWidget;
  @ISA = MyClass->class( 'Logging', 'UpperCase' );
  sub foo { local $_ = (shift)->NEXT('foo', @_); tr[a-z][z-a]; $_ }

  package main;
  print MyClass::CustomWidget->new()->foo();

=item Inheriting with a Factory Class

A subclass can use a factory class to define its own inheritance:

  package MyClass::CustomWidget;
  use Class::MixinFactory -isasubclass,
	MyClass::Factory => 'Logging', 'UpperCase';
  sub foo { local $_ = (shift)->NEXT('foo', @_); tr[a-z][z-a]; $_ }

  package main;
  print MyClass::CustomWidget->new()->foo();

=back

=head2 Configuring a Factory

Factories support methods that control which classes they will use.

The base class will be inherited from by all mixed classes. 

  $factory->base_class( "HelloWorld" );

The mixin prefix is prepended to the mixin names passed to the class() method. Mixin names that contain a "::" are assumed to be fully qualified and are not changed. If empty, the base_class is used.

  $factory->mixin_prefix( 'HelloFeature' );

The mixed prefix is at the start of all generated class names. If empty, the base_class is used, or the factory's class name.

  $factory->mixed_prefix( 'HelloClass' );

=head2 Writing a Mixin Class

Writing a mixin class is almost the same as writing a subclass, except where methods need to redispatch to the base-class implementation. (The SUPER::method syntax will only search for classes that the mixin itself inherits from; to search back up the inheritance tree and explore other branches, another redispatch mechanism is needed.) 

A method named NEXT is provided to continue the search through to the next class which provides a given method. The order in which mixins are stacked is significant, so the caller should understand how their behaviors interact. (See L<Class::MixinFactory::NEXT>.)

=head1 SEE ALSO

For distribution, installation, support, copyright and license 
information, see L<Class::MixinFactory::ReadMe>.

=cut
