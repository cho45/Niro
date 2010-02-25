package Text::MicroMason::Cache::Simple;

use strict;

######################################################################

sub new { my $class = shift; bless { @_ }, $class }

sub get { $_[0]->{ $_[1] } }

sub set { $_[0]->{ $_[1] } = $_[2] }

sub clear { %{ $_[0] } = () }

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::Cache::Simple - Basic Cache with Minimal Interface


=head1 DESCRIPTION

This trivial cache class just stores values in a hash. 

It does not perform any of the following functions: expiration, cache size limiting, flatening of complex keys, or deep copying of complex values.

=head2 Public Methods

=over 4

=item new()

  $cache = Text::MicroMason::Cache::Simple->new();

=item get()

  $value = $cache->get( $key );

Retrieves the value associated with this key, or undef if there is no value.

=item set()

  $cache->set( $key, $value );

Stores the provided value in association with this key. 

=item clear()

  $cache->clear();

Removes all data from the cache.

=back


=head1 SEE ALSO

For uses of this cache class, see L<Text::MicroMason::CompileCache>.

Additional cache classes are available in the Text::MicroMason::Cache:: namespace, or select other caching modules on CPAN that support the interface described in L<Cache::Cache>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
