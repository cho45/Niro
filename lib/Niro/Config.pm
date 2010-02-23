package Niro::Config;

use strict;
use warnings;

use Path::Class;
use Config::Tiny;

my $root   = file(__FILE__)->dir->parent->parent;
my $config = Config::Tiny->read($root->file('niro.conf'));

my $instance;

sub instance {
	my ($class) = @_;
	bless $config, $class;
}

sub root {
	$root;
}



1;
__END__



