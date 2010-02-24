package Niro::Model::Schema;
use DBIx::Skinny::Schema;
use DateTime;

my $dtf = 'DateTime::Format::SQLite';
$dtf->use or die $@;

install_utf8_columns qw/title body name/;

install_inflate_rule '_at$' => callback {
	inflate {
		$dtf->parse_datetime($_[0]);
	};
	deflate {
		$dtf->format_datetime($_[0]);
	};
};


install_table entry => schema {
	pk 'id';
	columns qw(
		id
		title 
		body 
		modified_at 
		created_at
	);
	
	trigger pre_insert => callback {
		my ($class, $args, $table) = @_;
		$args->{created_at} = $args->{modified_at} = DateTime->now;
	};

	trigger pre_update => callback {
		my ($class, $args, $table) = @_;
		$args->{modified_at} = DateTime->now;
	};

	trigger post_insert => callback {
		my ($class, $obj, $table) = @_;
		$obj->update_tags;
	};
};

install_table tag => schema {
	pk 'id';
	columns qw(
		id
		name
		entry_id
	);
};

1;
