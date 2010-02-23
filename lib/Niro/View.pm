package Niro::View;

use strict;
use warnings;
use utf8;

use Exporter::Lite;
use Encode;
our @EXPORT = qw(html json);

sub html {
	my ($r, $name) = @_;
	Text::MicroMason->use or die;
	my $m  = Text::MicroMason->new(qw/ -SafeServerPages -AllowGlobals /);
	# $m->set_globals(map { ("\$$_", $r->stash->{$_}) } keys %{ $r->stash });
	$m->set_globals("\$r", $r);

	my $template = decode_utf8($r->config->root->file('templates', $name)->slurp);
	eval {
		my $content = $m->execute(text => $template);

		$r->res->header("Content-Type" => "text/html");
		$r->res->body(encode_utf8($content));
	};
	if ($@) {
		die $@ ;
	}
}


sub json ($) {
	my ($r, $obj) = @_;
	JSON::XS->use or die;
	my $json = encode_json($obj);

	$r->res->header("Content-Type" => "application/json");
	$r->res->body($json);
}



1;
__END__



