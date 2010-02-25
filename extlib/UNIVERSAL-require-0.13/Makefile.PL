#!/usr/bin/perl -w

use ExtUtils::MakeMaker;

my $name = 'UNIVERSAL::require';
my $version_from = "lib/$name.pm";
$version_from =~ s{::}{/}g;

my $mm_ver = $ExtUtils::MakeMaker::VERSION;
if ($mm_ver =~ /_/) { # dev version
    $mm_ver = eval $mm_ver;
    die $@ if $@;
}

WriteMakefile(
    NAME         => 'UNIVERSAL::require',
    
    VERSION_FROM        => $version_from,
    ABSTRACT_FROM       => $version_from,
    AUTHOR              => 'Michael G Schwern <schwern@pobox.com>',

    PREREQ_PM    => {
        Test::More => 0.47
    },

    ($mm_ver >= 6.31 ? (LICENSE => 'perl') : ()),

    ($mm_ver <= 6.45 ? () : (META_MERGE => {
        resources => {
            license     =>      'http://dev.perl.org/licenses/',
            bugtracker  =>      'http://rt.cpan.org/Public/Dist/Display.html?Name=UNIVERSAL-require',
            repository  =>      'http://svn.schwern.org/repos/CPAN/UNIVERSAL-require/trunk/',
        },

        no_index => {
            package => ["UNIVERSAL"]
        },
    }))
);
