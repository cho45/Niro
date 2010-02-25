# A template for Makefile.PL.
# - Set the $PACKAGE variable to the name of your module.
# - Set $LAST_API_CHANGE to reflect the last version you changed the API
#   of your module.
# - Fill in your dependencies in PREREQ_PM
# Alternatively, you can say the hell with this and use h2xs.

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'parent',
    VERSION_FROM    => "lib/parent.pm", # finds $VERSION
    PREREQ_PM       => { Test::More => 0.40 },
    INSTALLDIRS => ($] >= 5.010001 ? 'perl' : 'site'),
);

# Leftover voodoo for testing various Perl distributions
{
    package MY;

    sub test_via_harness {
        my($self, $orig_perl, $tests) = @_;

        my @perls = ($orig_perl);
        push @perls, qw(bleadperl
                        perl5.6.1
                        perl5.6.0
                        perl5.005_03
                        perl5.004_05
                        perl5.004_04
                        perl5.004)
          if $ENV{PERL_TEST_ALL};

        my $out;
        foreach my $perl (@perls) {
            $out .= $self->SUPER::test_via_harness($perl, $tests);
        }

        return $out;
    }
}

1; # so you can require this Makefile.PL
