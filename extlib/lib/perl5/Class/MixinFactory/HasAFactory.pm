package Class::MixinFactory::HasAFactory;

use Class::MixinFactory::NEXT;
@ISA = 'Class::MixinFactory::NEXT';

use strict;

########################################################################

use Class::MixinFactory::InsideOutAttr 'mixin_factory_ref';

sub mixin_factory {
  my $self = shift;
  my $base_class = ref($self) || $self;
  $base_class->mixin_factory_ref() or $base_class->mixin_factory_ref(
      Class::MixinFactory::Factory->new( base_class => $base_class )
  )
}

sub class {
  (shift)->mixin_factory()->class( @_ )
}

########################################################################

1;

__END__

=head1 NAME

Class::MixinFactory::HasAFactory - Delegates to a Factory

=head1 SYNOPSIS

  package My::BaseClass;
  @ISA = 'Class::MixinFactory::HasAFactory';
  sub new { ... }
  sub foo { return "Foo Bar" }

  package My::Logging;
  sub foo { warn "Calling foo"; (shift)->NEXT('foo', @_) }

  package My::UpperCase;
  sub foo { uc( (shift)->NEXT('foo', @_) ) }

  package main;
  use My::BaseClass;
  print My::BaseClass->class()->new()->foo();
  print My::BaseClass->class( 'Logging' )->new()->foo();
  print My::BaseClass->class( 'UpperCase' )->new()->foo();
  print My::BaseClass->class( 'Logging', 'UpperCase' )->new()->foo();


=head1 DESCRIPTION

A class for use by classes which want a factory method.

Inherit from this class to obtain the class() factory method, described below.

=head1 PUBLIC METHODS

=over 4

=item mixin_factory()

  BaseClass->mixin_factory() : $factory_object

Gets the associated mixin factory. Generated the first time it is needed.

=item class()

  BaseClass->class( @mixins ) : $package_name

Calls the class() method on the associated mixin factory.

=back

=head1 SEE ALSO

For a facade interface that facilitates access to this functionality, see L<Class::MixinFactory>.

For distribution, installation, support, copyright and license 
information, see L<Class::MixinFactory::ReadMe>.

=cut
