package Class::MixinFactory::InsideOutAttr;

use strict;

########################################################################

sub import {
  my $methodmaker = shift;
  my $target_class = ( caller )[0];
  no strict 'refs';
  foreach my $attr ( @_ ) {
    *{ $target_class . '::' . $attr } = sub { inside_out( $attr, @_ ) }
  }
  defined *{ $target_class . '::' . 'DESTROY' }{CODE} 
       or *{ $target_class . '::' . 'DESTROY' } = \&destroy;
}

my %inside_out;

sub inside_out {
  my $callee = shift;
  my $key = shift;
  if ( $key eq 'DESTROY' ) {
    delete $inside_out{ $callee };
  } elsif ( ! scalar @_ ) {
    $inside_out{ $callee }{ $key }
  } else {
    $inside_out{ $callee }{ $key } = shift;
  }
}

sub destroy {
  my $callee = shift;
  delete $inside_out{ $callee };
}

########################################################################

1;

__END__

=head1 NAME

Class::MixinFactory::InsideOutAttr - Method maker for inside out data

=head1 SYNOPSIS

  package My::Class;
  use Class::MixinFactory::InsideOutAttr qw( foo bar baz );

  sub new { ... } 

  package main;

  My::Class->foo( 'Foozle' );
  print My::Class->foo();

  my $object = My::Class->new();

  $object->foo( 'Bolix' );
  print $object->foo();


=head1 DESCRIPTION

A simple method maker with opaque data storage.

=head2 Usage

To generate accessor methods for your class, use this package and pass the desired method names to the use or import statement.

Generates get/set accessor methods which can store values for a class or its instances. Each method stores the values associated with various objects in an hash keyed by the object's stringified identity. 

=head2 Destruction

A DESTROY method is installed to remove data for expired objects from the storage hash. (If the DESTROY method is not called, your program will not release this data and memory will be wasted.) 

If you implement your own DESTROY method, it should also call C<Class::MixinFactory::InsideOutAttr::destroy($self)>.

=head1 SEE ALSO

This class is used internally by L<Class::MixinFactory>.

This is similar to the functionality provided by Class::MakeMethods::Template::InsideOut; for a more generalized approach to this issue see L<Class::MakeMethods>.

For distribution, installation, support, copyright and license 
information, see L<Class::MixinFactory::ReadMe>.

=cut
