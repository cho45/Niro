package Niro::Model::Row::Entry;
use strict;
use warnings;
use base 'DBIx::Skinny::Row';

use Text::Hatena;
sub formatted_body {
	my ($self) = @_;
	Text::Hatena->parse($self->body);
}

sub as_stash {
	my ($self) = @_;
	+{
		id             => $self->id,
		title          => $self->title,
		body           => $self->body,
		formatted_body => $self->formatted_body,
	}
}

1;

