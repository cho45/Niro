
use strict;
use warnings;

use UNIVERSAL::require;
use Test::More;
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


Niro::Model->do($_) for split /;/, do {
	my $schema = Niro->config->root->file('db', 'schema.sql')->slurp;
	$schema =~ s/;\s*$//;
	$schema;
};

subtest "basic entry insert" => sub {
	my $e1 = Niro::Model->insert('entry', {
		title => "test",
		body  => "body",
	});

	is $e1->id, 1;
	is $e1->title, "test";
	is $e1->body,  "body";
	is $e1->created_at, $e1->modified_at;
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

	done_testing;
};

subtest "tagged entry" => sub {
	my $e1 = Niro::Model->insert('entry', {
		title => "test",
		body  => "body [tag1] [tag2]",
	});
	is_deeply $e1->tags, [qw/tag1 tag2/];
	
	$e1->set({ body => "body [tag1] [tag2] [tag3]" });
	$e1->update;

	is_deeply $e1->tags, [qw/tag1 tag2 tag3/];

	$e1->set({ body => "body [tag2] [tag3]" });
	$e1->update;

	is_deeply $e1->tags, [qw/tag2 tag3/];

	done_testing;
};

subtest "pager" => sub {
	my $e4 = Niro::Model->insert('entry', { title => 'a', body => 'body' });
	my $e3 = Niro::Model->insert('entry', { title => 'a', body => 'body' });
	my $e2 = Niro::Model->insert('entry', { title => 'a', body => 'body' });
	my $e1 = Niro::Model->insert('entry', { title => 'a', body => 'body' });
	my $e0 = Niro::Model->insert('entry', { title => 'a', body => 'body' });

	my ($page, $entries);

	$page = Niro::Model->page(q{
		SELECT * FROM entry
		ORDER BY created_at DESC
		LIMIT 2
	});
	$page->page(1);

	$entries = $page->entries;
	is scalar @$entries, 2;
	is $entries->[0]->id, $e0->id;
	is $entries->[1]->id, $e1->id;

	$page = Niro::Model->page(q{
		SELECT * FROM entry
		ORDER BY created_at DESC
		LIMIT 2
	});
	$page->page(2);

	$entries = $page->entries;
	is scalar @$entries, 2;
	is $entries->[0]->id, $e2->id;
	is $entries->[1]->id, $e3->id;

	$page = Niro::Model->page(q{
		SELECT * FROM entry
		ORDER BY created_at DESC
		LIMIT 2
	});
	$page->page(3);

	$entries = $page->entries;
	is $entries->[0]->id, $e4->id;

	done_testing;
};


done_testing;
