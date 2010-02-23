package Niro::Model::Row::Entry;
use strict;
use warnings;
use base 'DBIx::Skinny::Row';

sub formatted_body {
	my ($self) = @_;
	$self->body;
}

1;

