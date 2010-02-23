package Niro::Model::Row::Entry;
use strict;
use warnings;
use base 'DBIx::Skinny::Row';

use Text::Hatena;
sub formatted_body {
	my ($self) = @_;
	Text::Hatena->parse($self->body);
}

1;

