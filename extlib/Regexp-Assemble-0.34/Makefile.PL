# Makefile.PL for Regexp-Assemble

use ExtUtils::MakeMaker qw( WriteMakefile prompt );

eval "use ExtUtils::MakeMaker::Coverage";
if( $@ ) {
    print "Skipping testcover target, ExtUtils::MakeMaker::Coverage not found\n";
}
else {
    print "Adding testcover target\n";
}

my $file = [];
#if( my $response = prompt( 'Install eg/assemble as a program (y/N)', 'n' )) {
#    push @$file, "eg/assemble" if $response =~ /^\s*y/im,
#}

my @license = $ExtUtils::MakeMaker::VERSION > 6.30
    ? qw(LICENSE perl)
    : ();

WriteMakefile(
    NAME          => 'Regexp::Assemble',
    ABSTRACT_FROM => 'Assemble.pm',
    VERSION_FROM  => 'Assemble.pm',
    AUTHOR        => 'David Landgren',
    EXE_FILES     => $file,
    clean => {
        FILES => 'cover_db',
    },
    @license,
);
