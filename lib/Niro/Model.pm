package Niro::Model;

use strict;
use warnings;

use Niro::Config;
use DBIx::Skinny setup => +{
	dsn => 'dbi:SQLite:' . Niro::Config->instance->root->file('db.db'),
	username => '',
	password => '',
};

{
	no warnings 'redefine';
	sub search {
		my ($self, $sql, $hash, $array, $name) = @_;
		unless ($name) {
			($name) = ($sql =~ /FROM ([^\s]+)/i)
		}
		$self->search_named($sql, $hash || {}, $array || [], $name);
	}
}


1;
