use Test;
BEGIN { plan tests => 12 }

{

  package HelloWorld;
  use Class::MixinFactory -hasafactory;
  sub hello { return "Hello World!" }
  
  package HelloWorld::UpperCase;
  sub hello { uc( (shift)->NEXT('hello', @_) ) }
  
  package HelloWorld::Bold;
  sub hello { "<b>" . (shift)->NEXT('hello', @_) . "</b>" }
  
  package HelloWorld::Italic;
  sub hello { "<i>" . (shift)->NEXT('hello', @_) . "</i>" }

}

package main;

ok( HelloWorld->hello(), 'Hello World!' );

ok( HelloWorld->class()->hello(), 'Hello World!' );

ok( HelloWorld->class( 'Bold' )->hello(), '<b>Hello World!</b>' );
ok( HelloWorld->class( 'Italic' )->hello(), '<i>Hello World!</i>' );
ok( HelloWorld->class( 'UpperCase' )->hello(), 'HELLO WORLD!' );

ok( HelloWorld->class( 'Bold', 'Italic' )->hello(), '<b><i>Hello World!</i></b>' );
ok( HelloWorld->class( 'Italic', 'Bold' )->hello(), '<i><b>Hello World!</b></i>' );
ok( HelloWorld->class( 'Bold', 'UpperCase' )->hello(), '<b>HELLO WORLD!</b>' );
ok( HelloWorld->class( 'UpperCase', 'Bold' )->hello(), '<B>HELLO WORLD!</B>' );
ok( HelloWorld->class( 'Italic', 'UpperCase' )->hello(), '<i>HELLO WORLD!</i>');
ok( HelloWorld->class( 'UpperCase', 'Italic' )->hello(), '<I>HELLO WORLD!</I>');

ok( HelloWorld->class( 'UpperCase', 'Bold', 'Italic' )->hello(), '<B><I>HELLO WORLD!</I></B>');

