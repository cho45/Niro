#!/bin/sh

rm -rf extlib
mkdir extlib
cd extlib
wget http://search.cpan.org/CPAN/authors/id/C/CO/CORION/parent-0.223.tar.gz
wget http://search.cpan.org/CPAN/authors/id/N/NU/NUFFIN/Try-Tiny-0.04.tar.gz
wget http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/Devel-StackTrace-1.22.tar.gz
wget http://search.cpan.org/CPAN/authors/id/M/MI/MIYAGAWA/Devel-StackTrace-AsHTML-0.05.tar.gz
wget http://search.cpan.org/CPAN/authors/id/M/MS/MSCHWERN/UNIVERSAL-require-0.13.tar.gz
wget http://search.cpan.org/CPAN/authors/id/K/KW/KWILLIAMS/Path-Class-0.18.tar.gz
wget http://search.cpan.org/CPAN/authors/id/M/MS/MSCHWERN/Exporter-Lite-0.02.tar.gz
wget http://search.cpan.org/CPAN/authors/id/M/MR/MRAMBERG/HTTP-Body-1.07.tar.gz
wget http://search.cpan.org/CPAN/authors/id/T/TJ/TJENNESS/File-Temp-0.22.tar.gz
wget http://search.cpan.org/CPAN/authors/id/A/AD/ADAMK/Config-Tiny-2.12.tar.gz
wget http://search.cpan.org/CPAN/authors/id/C/CF/CFAERBER/DateTime-Format-SQLite-0.11.tar.gz
wget http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/DateTime-Format-Builder-0.7901.tar.gz
wget http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/Class-Factory-Util-1.7.tar.gz
wget http://search.cpan.org/CPAN/authors/id/F/FE/FERRENCY/Text-MicroMason-2.07.tar.gz
wget http://search.cpan.org/CPAN/authors/id/S/SA/SATOH/Text-MicroMason-SafeServerPages-0.03.tar.gz
wget http://search.cpan.org/CPAN/authors/id/E/EV/EVO/Class-MixinFactory-0.92.tar.gz
wget http://search.cpan.org/CPAN/authors/id/D/DC/DCONWAY/Parse-RecDescent-1.964.tar.gz
wget http://search.cpan.org/CPAN/authors/id/D/DL/DLAND/Regexp-Assemble-0.34.tar.gz



for i in *.tar.gz
do
	tar xzvf $i
done

rm *.tar.gz*
