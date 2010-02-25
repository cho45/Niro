package Dummy;

use Exporter::Lite;
@EXPORT      = qw(&foo $foo);
@EXPORT_OK   = qw(&bar my_sum $bar);
$VERSION = 0.5;

$foo = 'foofer';
sub foo { 42 }

$bar = 'barfer';
sub bar { 23 }

sub my_sum (&@) { 
    my($sub, @list) = @_;

    foreach (@list) { $sum = $sub->($_, $sum || 0); }
    return $sum;
}

sub car { "yarblockos" }

return 23;
