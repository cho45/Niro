use strict;
use warnings;
use Test::Base;
use Text::Hatena::AutoLink;

filters {
    text => ['text_hatena_autolink', 'chomp'],
    html => ['chomp'],
};

sub text_hatena_autolink {
    Text::Hatena::AutoLink->parse(shift);
}

run_is;

__END__
=== http
--- text
http://www.hatena.com/
--- html
<a href="http://www.hatena.com/">http://www.hatena.com/</a>

=== http2
--- text
hatena: http://www.hatena.com/
--- html
hatena: <a href="http://www.hatena.com/">http://www.hatena.com/</a>

=== http3
--- text
hatena: http://www.hatena.com/
hatena(jp): http://www.hatena.ne.jp/
--- html
hatena: <a href="http://www.hatena.com/">http://www.hatena.com/</a>
hatena(jp): <a href="http://www.hatena.ne.jp/">http://www.hatena.ne.jp/</a>

=== http_image
--- text
[http://www.hatena.ne.jp/images/top/h1.gif:image]
--- html
<a href="http://www.hatena.ne.jp/images/top/h1.gif"><img src="http://www.hatena.ne.jp/images/top/h1.gif" alt="http://www.hatena.ne.jp/images/top/h1.gif" /></a>

=== http_image2
--- text
[http://www.hatena.ne.jp/images/top/h1.gif:image:w150]
--- html
<a href="http://www.hatena.ne.jp/images/top/h1.gif"><img src="http://www.hatena.ne.jp/images/top/h1.gif" alt="http://www.hatena.ne.jp/images/top/h1.gif" width="150" /></a>

=== http_image3
--- text
[http://www.hatena.ne.jp/images/top/h1.gif:image:h100]
--- html
<a href="http://www.hatena.ne.jp/images/top/h1.gif"><img src="http://www.hatena.ne.jp/images/top/h1.gif" alt="http://www.hatena.ne.jp/images/top/h1.gif" height="100" /></a>

=== http_title
--- text
This is our site. [http://www.hatena.ne.jp/:title=Hatena]
--- html
This is our site. <a href="http://www.hatena.ne.jp/">Hatena</a>

=== ftp
--- text
Here are our files. ftp://www.hatena.ne.jp/
--- html
Here are our files. <a href="ftp://www.hatena.ne.jp/">ftp://www.hatena.ne.jp/</a>

=== unbracket
--- text
I don't want to link to here. []http://dont.link.to.me/[].
--- html
I don't want to link to here. http://dont.link.to.me/.

=== mailto
--- text
send me a mail mailto:info@example.com
--- html
send me a mail <a href="mailto:info@example.com">mailto:info@example.com</a>
