use File::Spec;
use lib File::Spec->catdir('t', 'lib');
use strict;
use warnings;
use Test::Base;
use MyParser;

filters {
    text => ['my_parse', 'omit_indent', 'chomp'],
    html => ['omit_indent', 'chomp'],
};

sub my_parse { MyParser->parse(shift, 'body') }
sub omit_indent {
    (my $text = shift) =~ s/^[\t\s]+//gmo;
    return $text;
}

run_is;

__END__
=== h3
--- text
*Hello, World!
--- html
<div class="section">
  <h3>Hello, World!</h3>
</div>

=== h3_2
--- text
*1172604381*Hello, World!
--- html
<div class="section">
  <h3>Hello, World!<span class="timestamp">1172604381</span></h3>
</div>
