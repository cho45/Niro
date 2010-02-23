package Niro;

use strict;
use warnings;
use utf8;

use Path::Class;
use Config::Tiny;
use Digest::SHA1;

use Niro::Router;
use Niro::Request;
use Niro::View;
my $root = file(__FILE__)->dir->parent;
my $config = Config::Tiny->read($root->file('niro.conf'));

route '/', action => sub {
	my ($r) = @_;
	$r->stash(title => 'test', content => 'foo');
	$r->html('index.html');
};

route '/login', method => GET,  action => sub { shift->html('login.html') };
route '/login', method => POST, action => sub {
	my ($r) = @_;
	my $password = $r->req->param('password') || "";
	if ($password eq $config->{_}->{password}) {
		$r->login(new => 1);
		$r->res->redirect($r->uri_for('/'));
	} else {
		$r->stash->{error} = "Invalid Password";
		$r->html('login.html');
	}
};
route '/logout', method => GET,  action => sub {
	my ($r) = @_;
	$r->login(logout => 1);
	$r->res->redirect($r->uri_for('/'));
};

route '/api/post', method => POST, action => sub {
	my ($r) = @_;
	$r->stash(title => 'test', content => 'foo');
	$r->html('index.html');
};

sub login {
	my ($r, %opts) = @_;
	if ($opts{new}) {
		my $rk = Digest::SHA1::sha1_hex(join("", time, rand, $$, []));
		$r->res->cookies->{rk} = $rk;
		my $fh = file("/tmp/session_$rk")->open('w');
		$fh->write(scalar time);
		$fh->close;
		1;
	} elsif ($opts{logout}) {
		my $rk = $r->req->cookies->{rk};
		my $session = file("/tmp/session_$rk");
		(-f $session) && ($session->remove);
		0;
	} else {
		my $rk = $r->req->cookies->{rk};
		my $session = file("/tmp/session_$rk");
		(-f $session) && ($session->slurp > (scalar time - (60 * 60 * 24 * 30)));
	}
}

sub uri_for {
	my ($r, $path, $args) = @_;
	$path =~ s{^/}{};
	my $uri = $r->req->base;
	$uri->path($uri->path . $path);
	$uri->query_form(@$args) if $args;
	$uri;
}

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

sub config {
	$config;
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



