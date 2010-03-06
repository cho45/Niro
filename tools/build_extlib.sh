#!/bin/sh

script=`readlink -f $0`
root=`dirname $script`/..

if [ "$1" = "--init" ]; then
	cd $root
	echo Setup local::lib
	mkdir tmp
	cd tmp
	wget http://search.cpan.org/CPAN/authors/id/A/AP/APEIRON/local-lib-1.004009.tar.gz
	tar xzvf local-lib*.tar.gz
	cd local-lib*
	perl Makefile.PL --bootstrap=$root/extlib --no-manpages
	make
	make install
	cd ..
	cd ..
	rm -rf tmp
fi

cd $root
echo Install deps to $root
eval `perl -I$root/extlib/lib/perl5 -Mlocal::lib=$root/extlib`

perl tools/cpanm --notest parent
perl tools/cpanm --notest Try::Tiny
perl tools/cpanm --notest Devel::StackTrace
perl tools/cpanm --notest Devel::StackTrace::AsHTML
perl tools/cpanm --notest Path::Class
perl tools/cpanm --notest Exporter::Lite
perl tools/cpanm --notest HTTP::Body
perl tools/cpanm --notest Config::Tiny
perl tools/cpanm --notest DateTime::Format::Builder
perl tools/cpanm --notest DateTime::Format::SQLite
perl tools/cpanm --notest Text::MicroMason
perl tools/cpanm --notest Text::MicroMason::SafeServerPages
perl tools/cpanm --notest Class::Factory::Util
perl tools/cpanm --notest Class::MixinFactory
perl tools/cpanm --notest JSON
perl tools/cpanm --notest List::MoreUtils
perl tools/cpanm --notest Cache::FileCache
perl tools/cpanm --notest URI::Escape

