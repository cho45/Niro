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

  package HelloWorld::Factory;
  use Class::MixinFactory -isafactory;
  HelloWorld::Factory->base_class( "HelloWorld" );

}

package main;

ok( HelloWorld->hello(), 'Hello World!' );

ok( HelloWorld::Factory->class()->hello(), 'Hello World!' );

ok( HelloWorld::Factory->class( 'Bold' )->hello(), '<b>Hello World!</b>' );
ok( HelloWorld::Factory->class( 'Italic' )->hello(), '<i>Hello World!</i>' );
ok( HelloWorld::Factory->class( 'UpperCase' )->hello(), 'HELLO WORLD!' );

ok( HelloWorld::Factory->class( 'Bold', 'Italic' )->hello(), '<b><i>Hello World!</i></b>' );
ok( HelloWorld::Factory->class( 'Italic', 'Bold' )->hello(), '<i><b>Hello World!</b></i>' );
ok( HelloWorld::Factory->class( 'Bold', 'UpperCase' )->hello(), '<b>HELLO WORLD!</b>' );
ok( HelloWorld::Factory->class( 'UpperCase', 'Bold' )->hello(), '<B>HELLO WORLD!</B>' );
ok( HelloWorld::Factory->class( 'Italic', 'UpperCase' )->hello(), '<i>HELLO WORLD!</i>');
ok( HelloWorld::Factory->class( 'UpperCase', 'Italic' )->hello(), '<I>HELLO WORLD!</I>');

ok( HelloWorld::Factory->class( 'UpperCase', 'Bold', 'Italic' )->hello(), '<B><I>HELLO WORLD!</I></B>');
