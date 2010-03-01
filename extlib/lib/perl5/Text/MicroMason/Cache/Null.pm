package Text::MicroMason::Cache::Null;

use strict;

######################################################################

sub new { my $class = shift; bless { @_ }, $class }

sub get { return }

sub set { return $_[2] }

sub clear { return }

######################################################################

1;

__END__

######################################################################

=head1 NAME

Text::MicroMason::Cache::Null - Trivial Cache with No Data Storage


=head1 DESCRIPTION

This trivial cache class supports the cache interface but doesn't store or retrieve any values. 

=head2 Public Methods

=over 4

=item new()

  $cache = Text::MicroMason::Cache::Null->new();

=item get()

  undef = $cache->get( $key );

Does nothing.

=item set()

  $cache->set( $key, $value );

Returns the provided value.

=item clear()

  $cache->clear();

Does nothing.

=back


=head1 SEE ALSO

For uses of this cache class, see L<Text::MicroMason::ExecuteCache>.

Additional cache classes are available in the Text::MicroMason::Cache:: namespace, or select other caching modules on CPAN that support the interface described in L<Cache::Cache>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
