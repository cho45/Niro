use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Text::Hatena',
    'VERSION_FROM' => 'lib/Text/Hatena.pm', # finds $VERSION
    'PREREQ_PM' => {
        Parse::RecDescent => 1.94,
        Regexp::Assemble => 0.28,
        Test::More => 0.32,
        Test::Base => 0.53,
    },
);
