package Niro;

use strict;
use warnings;
use utf8;

use Niro::Router;
use Niro::Request;
use Niro::View;
use Path::Class;
my $root = file(__FILE__)->dir->parent;

my $config = {
};

route '/',
	method => GET,
	action => sub {
		my ($r) = @_;
		$r->stash(title => 'test', content => 'foo');
		$r->html('index.html');
	};

sub run {
	my ($env) = @_;
	my $req = Niro::Request->new($env);
	my $res = $req->new_response;
	my $niro = Niro->new(
		req => $req,
		res => $res,
	);
	$niro->_run;
}

sub new {
	my ($class, %opts) = @_;
	bless {
		%opts
	}, $class;
}

sub root {
	$root;
}

sub _run {
	my ($self) = @_;
	Niro::Router->dispatch($self);
	$self->res->finalize;
}

sub req { $_[0]->{req} }
sub res { $_[0]->{res} }
sub log {
	my ($class, $format, @rest) = @_;
	print STDERR sprintf($format, @rest) . "\n";
}

sub stash {
	my ($self, %params) = @_;
	$self->{stash} = {
		%{ $self->{stash} || {} },
		%params
	};
	$self->{stash};
}


1;
__END__



