package Text::MicroMason::CompileCache;

use strict;
use Carp;

require Text::MicroMason::Cache::Simple;
require Text::MicroMason::Cache::File;

######################################################################
# What cache class should we use for each src_type?

my %CACHE_CLASS = (
                   file => 'Text::MicroMason::Cache::File',
                   text => 'Text::MicroMason::Cache::Simple',
                  );

######################################################################

# $code_ref = compile( file => $filename );
sub compile {
    my $self = shift;
    my ( $src_type, $src_data, %options ) = @_;
    my $cache = $self->_compile_cache( $src_type )
        or return $self->NEXT('compile', @_);
    my $key = $self->cache_key(@_);
    $cache->get( $key ) or $cache->set( $key,
                                        $self->NEXT('compile', @_),
                                      );
}

sub _compile_cache {
    my ($self, $type) = @_;
    $CACHE_CLASS{$type} or return;
    
    $self->{compile_cache}{$type} ||= $CACHE_CLASS{$type}->new();
}

######################################################################


1;

__END__

=head1 NAME

Text::MicroMason::CompileCache - Use a Cache for Template Compilation


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason->new( -CompileCache );

Use the standard compile and execute methods to parse and evalute templates:

    print $mason->execute( text=>$template, 'name'=>'Dave' );

The template does not have to be parsed the second time because it's cached:

    print $mason->execute( text=>$template, 'name'=>'Bob' );

Templates stored in files are also cached, until the file changes:

    print $mason->execute( file=>"./greeting.msn", 'name'=>'Charles');


=head1 DESCRIPTION


=head2 Public Methods

=over 4

=item compile()

Caching wrapper around normal compile() behavior.

=back

=head2 Supported Attributes

=over 4

=item compile_cache_text

Defaults to an instance of Text::MicroMason::Cache::Simple. You may pass in your own cache object.

=item compile_cache_file

Defaults to an instance of Text::MicroMason::Cache::File. You may pass in your own cache object.

=back

This module uses a simple cache interface that is widely supported: the
only methods required are C<get($key)> and C<set($key, $value)>. You can
use the simple cache classes provided in the Text::MicroMason::Cache::
namespace, or select other caching modules on CPAN that support the
interface described in L<Cache::Cache>.


=head1 SEE ALSO

For an overview of this templating framework, see L<Text::MicroMason>.

This is a mixin class intended for use with L<Text::MicroMason::Base>.

For distribution, installation, support, copyright and license 
information, see L<Text::MicroMason::Docs::ReadMe>.

=cut
