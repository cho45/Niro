package Niro::Model;

use strict;
use warnings;

use Niro;
use DBIx::Skinny setup => +{
	dsn => 'dbi:SQLite:' . Niro->root->file('db.db'),
	username => '',
	password => '',
};


1;
