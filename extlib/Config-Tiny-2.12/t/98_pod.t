#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}
use Test::More;

# Skip if doing a regular install
unless ( $ENV{AUTOMATED_TESTING} ) {
	plan( skip_all => "Author tests not required for installation" );
}

# Load the testing modules if we can
eval "use Test::Pod 1.00";
if ( $@ ) {
	plan( skip_all => "Test::Pod not available for testing" );
}

all_pod_files_ok();
exit(0);





#####################################################################
# WARNING: INSANE BLACK MAGIC
#####################################################################

# Hack Pod::Simple::BlackBox to ignore the Test::Inline
# "Extended Begin" syntax.
# For example, "=begin has more than one word errors"
my $begin;
if ( $Test::Pod::VERSION ) {
	$begin = \&Pod::Simple::BlackBox::_ponder_begin;
}
sub mybegin {
	my $para = $_[1];
	my $content = join ' ', splice @$para, 2;
	$content =~ s/^\s+//s;
	$content =~ s/\s+$//s;
	my @words = split /\s+/, $content;
	if ( $words[0] =~ /^test(?:ing)?\z/s ) {
		foreach ( 2 .. $#$para ) {
			$para->[$_] = '';
		}
		$para->[2] = $words[0];
	}

	# Continue as normal
	push @$para, @words;
	return &$begin(@_);
}

SCOPE: {
	local $^W = 0;
	if ( $Test::Pod::VERSION ) {
		*Pod::Simple::BlackBox::_ponder_begin = \&mybegin;
	}
}

#####################################################################
# END BLACK MAGIC
#####################################################################

