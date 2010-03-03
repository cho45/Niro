package Niro::Empty;

use strict;
use warnings;

sub new {
	my ($class) = @_;
	bless {}, $class;
}

sub AUTOLOAD {
	undef;
}


1;
__END__



