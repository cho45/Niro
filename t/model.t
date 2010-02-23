
use strict;
use warnings;

use UNIVERSAL::require;
use Test::More tests => 8;
use Test::Deep;
use File::Temp;
use Path::Class;
use Encode;

use lib glob 'modules/*/lib';

sub u8 ($) { decode_utf8(shift) };
sub is_utf8 ($;$) { ok utf8::is_utf8(shift), shift };

use Niro::Model;
use Niro;

Niro::Model->reconnect({
	dsn => 'dbi:SQLite:' . mktemp('/tmp/NiroTest-XXXX'),
});


my $schema = Niro->config->root->file('db', 'schema.sql')->slurp;
Niro::Model->do($schema);

my $e1 = Niro::Model->insert('entry', {
	title => "test",
	body  => "body",
});

is $e1->id, 1;
is $e1->title, "test";
is $e1->body,  "body";
ok $e1->formatted_body;
$e1->update;

my $e2 = Niro::Model->insert('entry', {
	title => u8 "たいとる",
	body  => u8 "ほんぶん",
});

is $e2->id, 2;
is_utf8 $e2->title;
is_utf8 $e2->body;

my $ee = Niro::Model->single('entry', { id => 1 });
ok $ee;


