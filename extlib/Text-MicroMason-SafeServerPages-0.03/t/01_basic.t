use strict;

use lib 'lib';

use Test::Base;
use Text::MicroMason;

plan tests => 1 * blocks;

filters {
	input => [qw/yaml mason/],
	expected => [qw/chomp/],
};

sub mason {
	my ($i) = @_;

	my $m = Text::MicroMason->new(qw/ -SafeServerPages /);
	$m->execute( text => $i->{text}, %{$i->{args}});
}

run_is input => 'expected';

__END__
=== Basic
--- input
text: <%= $ARGS{foo} %>
args:
  foo: <script/>
--- expected
&lt;script/&gt;

=== RAW
--- input
text: <%raw= $ARGS{foo} %>
args:
  foo: <script/>
--- expected
<script/>

=== Statement -> Expression
--- input
text: <%= $ARGS{foo}; %>
args:
  foo: <script/>
--- expected
&lt;script/&gt;
