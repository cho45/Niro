package Niro::Model::Row::Entry;
use strict;
use warnings;
use base 'DBIx::Skinny::Row';
use Niro::Model;
use DateTime;

use Text::Xatena;
use Text::Xatena::Inline::Aggressive;
use Cache::FileCache;
sub formatted_body {
	my ($self) = @_;
	Text::Xatena->new->format($self->body,
		inline => Text::Xatena::Inline::Aggressive->new(
			cache => Cache::FileCache->new({default_expires_in => 60 * 60 * 24 * 30})
		)
	);
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
	$body =~ s{\[\[([^\[\]]+)\]\]}{
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

sub path {
	my ($self) = @_;
	sprintf('/%d', $self->id);
}


sub ambtime {
	my ($self, $name) = @_;
	my $datetime = $self->$name;
	my $now = DateTime->now;
	my $delta = $now->epoch - $datetime->epoch;
	my $ret;

	if       ($delta <  60 * 60) {
		my $min = int($delta / (60));
		$ret = ($min > 3) ? $min . " minutes ago" : "a minutes ago";

	} elsif  ($delta <  60 * 60 * 24) {
		$ret = int($delta / (60 * 60)) . " hours ago";

	} elsif  ($delta <  60 * 60 * 24 * 3) {
		$ret = int($delta / (60 * 60 * 24)) . " days ago"

	} elsif  ($now->strftime("%Y") eq $datetime->strftime("%Y")) {
		$ret = $datetime->strftime("%m/%d");

	} else {
		$ret = $datetime->strftime("%Y-%m-%d");
	}

	$ret =~ s/0([1-9])/$1/g;
	$ret;
}

1;

