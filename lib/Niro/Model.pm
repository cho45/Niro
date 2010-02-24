package Niro::Model;

use strict;
use warnings;

use Niro::Config;
use Niro::Model::Page;
use DBIx::Skinny;

sub page {
	my ($self, $query, $hash, $array, $name) = @_;
	Niro::Model::Page->new($query, $hash, $array, $name);
}

sub select {
	my ($self, $sql, $hash, $array, $name) = @_;
	unless ($name) {
		($name) = ($sql =~ /FROM ([^\s]+)/i)
	}
	[ $self->search_named($sql, $hash || {}, $array || [], $name) ];
}


1;
