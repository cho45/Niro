use strict;
use warnings;

use Test::More 'no_plan';
use Parse::RecDescent;

my $parser = Parse::RecDescent->new(<<'EOG');

{
  my %ret;
}

CONFIG : KV_PAIR(s) { return \%ret }

KV_PAIR : WORD /\s*=\s*/ MAYBE_QUOTED_WORD { $ret{$item[1]} = $item[3] }

MAYBE_QUOTED_WORD:  WORD
                   | /'([^']+)'/  { $return = $1 }
                   | /"([^"]+)"/  { $return = $1 }

WORD : /\w+/

EOG

ok($parser, 'Created parser');

my $str = q|a=1 b="2" c ="33" d= '12'|;

my $result = $parser->CONFIG($str);

is_deeply($result, { a => 1, b => 2, c => 33, d => 12 } );
