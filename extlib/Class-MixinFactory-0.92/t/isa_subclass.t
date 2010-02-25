use Test;
BEGIN { plan tests => 4 }


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
  BEGIN { $INC{"HelloWorld/Factory.pm"} = __FILE__ }
  BEGIN { HelloWorld::Factory->base_class( "HelloWorld" ) }

}

{ 
  package My::FirstStyle; 
  use Class::MixinFactory -isasubclass => HelloWorld::Factory => 'UpperCase';
  sub hello { "* " . (shift)->NEXT('hello', @_) . " *" }

  package My::SecondStyle; 
  use Class::MixinFactory -isasubclass => HelloWorld::Factory => 'Bold', 'Italic';
  sub hello { "* " . (shift)->NEXT('hello', @_) . " *" }

  package My::ThirdStyle; 
  use Class::MixinFactory -isasubclass => HelloWorld::Factory => 'Bold', 'UpperCase';
  sub hello { "* " . (shift)->NEXT('hello', @_) . " *" }
}

package main;

ok( HelloWorld->hello(), 'Hello World!' );

ok( My::FirstStyle->hello(), '* HELLO WORLD! *' );
ok( My::SecondStyle->hello(), '* <b><i>Hello World!</i></b> *' );
ok( My::ThirdStyle->hello(), '* <b>HELLO WORLD!</b> *' );
