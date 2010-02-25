use strict;
use warnings;
use Test::Base;
use Text::Hatena::AutoLink;

Text::Hatena::AutoLink->syntax({
    'id:([\w-]+)' => sub {
        my $mvar = shift;
        my $name = $mvar->[1];
        return qq|<a href="/$name/">id:$name</a>|;
    },
    'd:id:([\w-]+)' => sub {
        my $mvar = shift;
        my $name = $mvar->[1];
        return qq|<a href="http://d.hatena.ne.jp/$name/">d:id:$name</a>|;
    },
});

filters {
    text => ['text_hatena_autolink', 'chomp'],
    html => ['chomp'],
};

sub text_hatena_autolink {
    Text::Hatena::AutoLink->parse(shift);
}

run_is;

__END__
=== id
--- text
Hello, id:jkondo!
--- html
Hello, <a href="/jkondo/">id:jkondo</a>!

=== d:id
--- text
Hello, id:jkondo!
Is this your blog? d:id:jkondo
--- html
Hello, <a href="/jkondo/">id:jkondo</a>!
Is this your blog? <a href="http://d.hatena.ne.jp/jkondo/">d:id:jkondo</a>
