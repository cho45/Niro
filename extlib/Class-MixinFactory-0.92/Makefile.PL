use ExtUtils::MakeMaker;

########################################################################

WriteMakefile(
    'NAME'		=> 'Class::MixinFactory',
    'VERSION_FROM'	=> 'MixinFactory.pm', 
    'PREREQ_PM'		=> {}, 

    ($] >= 5.005 ? (
      # ABSTRACT_FROM     => 'MixinFactory/ReadMe.pod', 
      AUTHOR            => 'Matthew Simon Cavalletto <simonm@cavalletto.org>',
    ) : ()),
);

########################################################################

sub MY::postamble { q{

cleandist: FORCE
	make again; make cleanmanifest; make docs; make dist

again: FORCE
	make clean; perl Makefile.PL; make pm_to_blib

cleanmanifest: realclean FORCE
	rm MANIFEST ; perl Makefile.PL; touch MANIFEST; make manifest

%.t: pm_to_blib FORCE
	make; perl -Iblib/lib $@

htmldoc: pm_to_blib FORCE
	perl make_extras/htmldoc.pl $(MAN3PODS)

cover: FORCE
	cover -delete; HARNESS_PERL_SWITCHES=-MDevel::Cover make test; cover

docs : README CHANGES

README: MixinFactory/ReadMe.pod
	pod2text MixinFactory/ReadMe.pod > README

CHANGES: MixinFactory/Changes.pod
	pod2text MixinFactory/Changes.pod > CHANGES

}; }
