use Test;
BEGIN { plan tests => 12 }

{

  package HelloWorld;
  sub hello { return "Hello World!" }
  
  package HelloWorld::UpperCase;
  sub hello { uc( (shift)->NEXT('hello', @_) ) }
  
  package HelloWorld::Bold;
  sub hello { "<b>" . (shift)->NEXT('hello', @_) . "</b>" }
  
  package HelloWorld::Italic;
  sub hello { "<i>" . (shift)->NEXT('hello', @_) . "</i>" }

}

package main;

use Class::MixinFactory;
my $factory = Class::MixinFactory->new();
$factory->base_class( "HelloWorld" );

ok( HelloWorld->hello(), 'Hello World!' );

ok( $factory->class()->hello(), 'Hello World!' );

ok( $factory->class( 'Bold' )->hello(), '<b>Hello World!</b>' );
ok( $factory->class( 'Italic' )->hello(), '<i>Hello World!</i>' );
ok( $factory->class( 'UpperCase' )->hello(), 'HELLO WORLD!' );

ok( $factory->class( 'Bold', 'Italic' )->hello(), '<b><i>Hello World!</i></b>' );
ok( $factory->class( 'Italic', 'Bold' )->hello(), '<i><b>Hello World!</b></i>' );
ok( $factory->class( 'Bold', 'UpperCase' )->hello(), '<b>HELLO WORLD!</b>' );
ok( $factory->class( 'UpperCase', 'Bold' )->hello(), '<B>HELLO WORLD!</B>' );
ok( $factory->class( 'Italic', 'UpperCase' )->hello(), '<i>HELLO WORLD!</i>');
ok( $factory->class( 'UpperCase', 'Italic' )->hello(), '<I>HELLO WORLD!</I>');

ok( $factory->class( 'UpperCase', 'Bold', 'Italic' )->hello(), '<B><I>HELLO WORLD!</I></B>');
