use strict;
use warnings;

use Test::More 'no_plan';
use Parse::RecDescent;

my $parser = Parse::RecDescent->new( q{
  sep:  some(?) '(' repeated(s? /,/) ')' 'elements'
  {
     $return = $item[3];
  }

  repeated: 'repeated'

  some: 'some'
    });

ok($parser, 'Created parser');

my $str = 'some (repeated, repeated, repeated, repeated) elements';
my $result = $parser->sep($str);

my $expected = ['repeated', 'repeated', 'repeated', 'repeated'];

is_deeply($result, $expected);
