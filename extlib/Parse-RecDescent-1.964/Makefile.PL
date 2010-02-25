use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Parse::RecDescent',
    AUTHOR           => 'Damian Conway <DCONWAY@CPAN.org>',
    VERSION_FROM     => 'lib/Parse/RecDescent.pm',
    ABSTRACT_FROM    => 'lib/Parse/RecDescent.pm',
    PL_FILES         => {},
    PREREQ_PM        => {
        'Text::Balanced' => 0,
        'Test::More'     => 0,
        'version'        => 0,
    },
    dist             => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean            => { FILES => 'Parse-RecDescent-*' },
);
