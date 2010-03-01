package Text::MicroMason::ExecuteCache;

use strict;
use Carp;

require Text::MicroMason::Base;
require Text::MicroMason::Cache::Simple;

######################################################################

# $code_ref = compile( text => $template );
sub compile {
    my $self = shift;
    
    my $code_ref = $self->NEXT('compile', @_);
    
    my $cache = $self->_execute_cache()
        or return $code_ref;
    
    sub {
        my $key = join("|", $code_ref, @_);
        $cache->get( $key ) or $cache->set( $key, $code_ref->( @_ ) );
    }
}

sub _execute_cache {
    my $self = shift;
    
    $self->{execute_cache} ||= Text::MicroMason::Cache::Simple->new();
}

######################################################################

1;

__END__

=head1 NAME

Text::MicroMason::ExecuteCache - Use a Cache for Template Results


=head1 SYNOPSIS

Instead of using this class directly, pass its name to be mixed in:

    use Text::MicroMason;
    my $mason = Text::MicroMason->new( -ExecuteCache );

Use the standard compile method to parse a template into a subroutine:

    my $subref = $mason->compile( text=>$template );
    print $subref->( 'name'=>'Dave' );

The template does not have to be interpreted the second time because 
the results are cached:

    print $subref->( 'name'=>'Dave' ); # fast second time

When run with different arguments, the template is re-interpreted 
and the results stored:

    print $subref->( 'name'=>'Bob' ); # first time for Bob

    print $subref->( 'name'=>'Bob' ); # fast second time for Bob


=head1 DESCRIPTION

Caches the output of templates.

Note that you should not use this feature if your template code interacts with any external state, such as making changes to an external data source or obtaining values that will change in the future. (However, you can still use the caching provided by L<Text::MicroMason::CompileCache>.)


=head2 Public Methods

=over 4

=item compile()

Wraps each template that is compiled into a Perl subroutine in a memoizing closure. 

=back

=head2 Supported Attributes

=over 4

=item execute_cache

Defaults to an instance of Text::MicroMason::Cache::Simple.

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
