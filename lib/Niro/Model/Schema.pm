package Niro::Model::Schema;
use DBIx::Skinny::Schema;
use DateTime;

my $dtf = 'DateTime::Format::SQLite';
$dtf->use or die $@;

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
		my ($class, $args) = @_;
		$args->{modified_at} = $args->{created_at} = DateTime->now;
	};

	trigger pre_update => callback {
		my ($class, $args) = @_;
		$args->{modified_at} = DateTime->now;
	};
};

install_inflate_rule '_at$' => callback {
	inflate {
		$dtf->parse_datetime($_[0]);
	};
	deflate {
		$dtf->format_datetime($_[0]);
	};
};


1;
