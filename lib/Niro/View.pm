package Niro::View;

use strict;
use warnings;
use utf8;

use Exporter::Lite;
our @EXPORT = qw(html json);

sub html {
	my ($r, $name) = @_;
	Text::MicroMason->use or die;
	my $m  = Text::MicroMason->new(qw/ -SafeServerPages -AllowGlobals /);
	$m->set_globals(map { ("\$$_", $r->stash->{$_}) } keys %{ $r->stash });

	my $template = $r->root->file('templates', $name)->slurp;
	my $content = $m->execute(text => $template);

	$r->res->header("Content-Type" => "text/html");
	$r->res->body($content);
}


sub json ($) {
}



1;
__END__



