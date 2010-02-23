package Niro::Router;

use strict;
use warnings;
use utf8;

use Exporter::Lite;
our @EXPORT = qw(route GET POST PUT HEAD);

sub GET  { "GET"  }
sub POST { "POST" }
sub PUT  { "PUT"  }
sub HEAD { "HEAD" }

our $routing = [];

sub route ($;%) {
	my ($path, %opts) = @_;
	my $regexp  = "^$path\$";
	my $capture = [];

	$regexp =~ s{([:*])(\w+)}{
		my $type = $1;
		my $name = $2;
		push @$capture, $name;
		sprintf("(%s)",
			$opts{$name} ||
			(($type eq "*") ? ".*": "[^\/]+")
		);
	}ge;

	push @$routing, {
		%opts,
		define  => $path,
		regexp  => $regexp,
		capture => $capture,
	};
}

sub dispatch {
	my ($class, $niro) = @_;
	my $path   = $niro->req->path;
	my $method = uc $niro->req->method;
	my $params = {};
	my $action;

	my $routing_info;
	for my $route (@$routing) {
		next if $route->{method} && ($route->{method} ne $method);
		if (my @capture = ($path =~ $route->{regexp})) {
			for my $name (@{ $route->{capture} }) {
				$params->{$name} = shift @capture;
			}
			$action = $route->{action};
			$routing_info = sprintf("%s %s => %s", $method, $path, $route->{define});
			$niro->req->logger({ level => debug => message => $routing_info });
			last;
		}
	}

	$niro->req->param(%$params);
	$niro->res->status(200);
	$niro->res->headers([
		'Content-Type'   => 'text/html',
		'X-Routing-Info' => $routing_info,
	]);
	if ($action) {
		$action->($niro);
		1;
	} else {
		$niro->res->status(404);
		0;
	}
}


1;
__END__



