package Niro::Model::Row::Entry;
use strict;
use warnings;
use base 'DBIx::Skinny::Row';
use Niro::Model;

use Text::Hatena;
sub formatted_body {
	my ($self) = @_;
	Text::Hatena->parse($self->body);
}

sub update {
	my ($self) = @_;
	my $ret = $self->SUPER::update;
	$self->update_tags;
	$ret;
}

sub update_tags {
	my ($self) = @_;

	my $tags = [];
	my $body = $self->body;
	$body =~ s{\[([^\[\]]+)\]}{
		push @$tags, $1;
	}eg;

	my $current = $self->tags;

	my $applied = do {
		my $table = {};
		$table->{$_} = 1 for @$tags;
		delete $table->{$_} for @$current;
		[ keys %$table ]
	};

	for my $name (@$applied) {
		Niro::Model->create('tag', { name => $name, entry_id => $self->id });
	}

	my $removed = do {
		my $table = {};
		$table->{$_} = 1 for @$current;
		delete $table->{$_} for @$tags;
		[ keys %$table ]
	};

	for my $name (@$removed) {
		Niro::Model->delete('tag', { name => $name, entry_id => $self->id });
	}
}

sub tags {
	my ($self) = @_;
	my $tags = Niro::Model->select(q{
		SELECT * FROM tag
		WHERE entry_id = :entry_id
	}, { entry_id => $self->id });

	[ map { $_->name } @$tags ];
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

