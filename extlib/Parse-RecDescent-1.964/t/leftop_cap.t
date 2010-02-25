use Parse::RecDescent;

my $grammar = q {
    nolcap : <leftop: id /\+|-/   id>
    lcap   : <leftop: id /(\+|-)/ id>

    norcap : <rightop: id /\+|-/   id>
    rcap   : <rightop: id /(\+|-)/ id>

    id : /[a-zA-Z][a-zA-Z_0-9\.]*/
};

my $parser = new Parse::RecDescent($grammar) or die "Bad Grammar";

use Test::More tests=>4;

my $text = "a + b - c + d";

is_deeply $parser->nolcap($text), [qw<a b c d>]       => 'Capturing leftop';
is_deeply $parser->lcap($text),   [qw<a + b - c + d>] => 'Noncapturing leftop';
is_deeply $parser->norcap($text), [qw<a b c d>]       => 'Capturing rightop';
is_deeply $parser->rcap($text),   [qw<a + b - c + d>] => 'Noncapturing rightop';
