package Niro;

use strict;
use warnings;
use utf8;

use Digest::SHA1;
use Path::Class;
use URI;

use Niro::Router;
use Niro::Request;
use Niro::View;
use Niro::Model;
use Niro::Config;


route '/', action => sub {
	my ($r) = @_;
	my $page = Niro::Model->page(q{
		SELECT * FROM entry
		ORDER BY created_at DESC
		LIMIT 5
	});
	$page->page($r->req->param('page') || 1);

	$r->stash(page => $page);
	$r->html('index.html');
};

route '/.rdf', action => sub {
	my ($r) = @_;
	my $page = Niro::Model->page(q{
		SELECT * FROM entry
		ORDER BY created_at DESC
		LIMIT 30
	});
	$page->page($r->req->param('page') || 1);

	$r->stash(page => $page);
	$r->html('entries.rdf');
	$r->res->header("Content-Type" => "application/rss+xml");
};

route '/:id', id => qr/\d+/, action => sub {
	my ($r) = @_;
	my $entry = Niro::Model->single('entry', { id => $r->req->param('id') });
	$r->stash(entry => $entry);
	$r->html('entry.html');
};

route '/:category/', category => qr/[a-z]+/, action => sub {
	my ($r) = @_;
	my $page = Niro::Model->page(q{
		SELECT entry.* FROM entry INNER JOIN tag ON entry.id = tag.entry_id
		WHERE tag.name = :name
		ORDER BY created_at DESC
		LIMIT 10
	}, { name => $r->req->param('category') });
	$page->page($r->req->param('page') || 1);

	$r->stash(page => $page);
	$r->html('index.html');
};

route '/login', method => GET,  action => sub { shift->html('login.html') };
route '/login', method => POST, action => sub {
	my ($r) = @_;
	my $password = $r->req->param('password') || "";
	if ($password eq Niro->config->{_}->{password}) {
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
	return $r->error(code => 403) unless $r->login;
	return $r->error(code => 403) unless $r->rks eq $r->req->param('rks');

	my $entry;
	if ($r->req->param('id')) {
		$entry = Niro::Model->single('entry', { id => $r->req->param('id') });
		return $r->json({ error => 'unkown entry' }) unless $entry;
		$entry->set({
			title => $r->req->param('title') || '',
			body  => $r->req->param('body')  || '',
		});
		$entry->update;
	} else {
		$entry = Niro::Model->insert('entry', {
			title => $r->req->param('title') || '',
			body  => $r->req->param('body')  || '',
		});
	}

	$r->json({
		entry => $entry->as_stash
	});
};

route '/api/info', method => GET, action => sub {
	my ($r) = @_;
	return $r->error(code => 403) unless $r->login;
	my $entry = Niro::Model->single('entry', { id => $r->req->param('id') });
	return $r->json({ error => 'unkown entry' }) unless $entry;

	$r->json({
		entry => $entry->as_stash
	});
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
		my $rk = $r->req->cookies->{rk} || "";
		my $session = file("/tmp/session_$rk");
		(-f $session) && ($session->slurp > (scalar time - (60 * 60 * 24 * 30)));
	}
}

sub rks {
	my ($r) = @_;
	Digest::SHA1::sha1_hex($r->req->cookies->{rk} || "");
}

sub uri_for {
	my ($r, $path, $args) = @_;
	my $uri = $r->req->base;
	$uri->path(($r->config->{_}->{root} || $uri->path) . $path);
	$uri->query_form(@$args) if $args;
	$uri;
}

sub abs_uri {
	my ($r, $path, $args) = @_;
	my $uri = URI->new($r->config->{_}->{base});
	$uri->path(($r->config->{_}->{root} || $uri->path) . $path);
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

sub config {
	Niro::Config->instance;
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

sub error {
	my ($self, %opts) = @_;
	$self->res->status($opts{code} || 500);
	$self->res->body($opts{message} || $opts{code} || 500);
}

my $db = Niro::Config->instance->root->file(($ENV{HTTP_HOST} || "") =~ /\blab\b/ ? 'test.db' : 'entry.db');
Niro::Model->connect_info({
	dsn => 'dbi:SQLite:' . $db,
});
unless (-f $db) {
	Niro::Model->do($_) for split /;/, do {
		my $schema = Niro->config->root->file('db', 'schema.sql')->slurp;
		$schema =~ s/;\s*$//;
		$schema;
	};
}

1;
__END__



