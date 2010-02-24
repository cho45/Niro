package Niro::Model::Page;

use strict;
use warnings;

sub new {
	my ($class, $query, $hash, $array, $name) = @_;
	my ($limit) = ($query =~ /limit (\d+)/i);
	bless {
		query => $query,
		hash  => $hash,
		array => $array,
		name  => $name,
		limit => $limit,
	}, $class;
}

sub page {
	my ($self, $page) = @_;
	$self->{page} = $page if $page;
	$self->{page};
}

sub limit {
	my ($self, $limit) = @_;
	$self->{limit} = $limit if $limit;
	$self->{limit};
}

sub entries {
	my ($self) = @_;
	$self->{_entries} ||= do {
		my $query = $self->{query};
		my $offset = $self->offset;
		my $limit  = $self->limit;
		$query =~ s{LIMIT\s+\d+(\s+OFFSET\s+\d+)?}{LIMIT $limit OFFSET $offset}i;
		Niro::Model->select($query, $self->{hash}, $self->{array}, $self->{name});
	};
}

# override
sub pager_html {
	my ($self) = @_;
	my $ret = "<div class='pager'>";
	if ($self->has_prev) {
		$ret .= sprintf('<a href="?page=%d" rel="prev">&lt;&lt;</a>', $self->current - 1);
	} else {
		$ret .= sprintf('<a rel="prev">&lt;&lt;</a>');
	}

	$ret .= sprintf('<strong class="current">%d</strong>', $self->current);

	if ($self->has_next) {
		$ret .= sprintf('<a href="?page=%d" rel="next">>></a>', $self->current + 1);
	} else {
		$ret .= sprintf('<a rel="next">>></a>');
	}

	$ret .= '</div>';
	$ret;
}

sub current {
	my ($self) = @_;
	$self->{page};
}

sub total {
	my ($self) = @_;
	defined $self->{_total} ? $self->{_total} : $self->{_total} = do {
		my $query = $self->{query};
		$query =~ s{SELECT\s+([^\s]+)}{SELECT count(*) AS total};
		Niro::Model->select($query, $self->{hash}, $self->{array}, $self->{name})->[0]->get_column('total')
	};
}

sub offset {
	my ($self) = @_;
	($self->{page} - 1) * $self->limit;
}

sub has_prev {
	my ($self) = @_;
	$self->{page} > 1;
}

sub has_next {
	my ($self) = @_;
	$self->offset + $self->limit < $self->total;
}


1;
__END__



