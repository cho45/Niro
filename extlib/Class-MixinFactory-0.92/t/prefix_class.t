use Test;
BEGIN { plan tests => 15 }

{

  package HelloWorld;
  sub hello { return "Hello World!" }
  
  package HelloFeature::UpperCase;
  sub hello { uc( (shift)->NEXT('hello', @_) ) }
  
  package HelloFeature::Bold;
  sub hello { "<b>" . (shift)->NEXT('hello', @_) . "</b>" }
  
  package HelloFeature::Italic;
  sub hello { "<i>" . (shift)->NEXT('hello', @_) . "</i>" }

  package HelloWorld::Factory;
  use Class::MixinFactory -isafactory;
  HelloWorld::Factory->base_class( "HelloWorld" );
  HelloWorld::Factory->mixin_prefix( 'HelloFeature' );
  HelloWorld::Factory->mixed_prefix( 'HelloClass' );

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

ok( HelloWorld::Factory->class(), 'HelloClass::Base' );
ok( HelloWorld::Factory->class( 'Bold' ), 'HelloClass::Bold' );
ok( HelloWorld::Factory->class( 'Bold', 'Italic' ), 'HelloClass::Bold_Italic' );
