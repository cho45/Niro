package MyParser;
use strict;
use warnings;
use base qw(Text::Hatena);

__PACKAGE__->syntax(q|
    h3 : "\n*" timestamp(?) inline(s)
    timestamp : /\d{9,10}/ '*'
|);

sub h3 {
    my $class = shift;
    my $items = shift->{items};
    my $title = $class->expand($items->[2]);
    return if $title =~ /^\*/;
    my $ret = "<h3>$title";
    if (my $time = $items->[1]->[0]) {
        $ret .= qq|<span class="timestamp">$time</span>|;
    }
    $ret .= "</h3>\n";
}

sub timestamp {
    my $class = shift;
    my $items = shift->{items};
    return $items->[0];
}

1;
