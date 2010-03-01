#!/bin/sh

root=`dirname $0`/../
eval `perl -I$root/extlib/lib/perl5 -Mlocal::lib=$root/extlib`

perl tools/cpanm parent
perl tools/cpanm Try::Tiny
perl tools/cpanm Try::Tiny
perl tools/cpanm Devel::StackTrace
perl tools/cpanm Devel::StackTrace::AsHTML
perl tools/cpanm Path::Class
perl tools/cpanm Exporter::Lite
perl tools/cpanm HTTP::Body
perl tools/cpanm Config::Tiny
perl tools/cpanm DateTime::Format::Builder
perl tools/cpanm DateTime::Format::SQLite
perl tools/cpanm Text::MicroMason
perl tools/cpanm Text::MicroMason::SafeServerPages
perl tools/cpanm Class::Factory::Util
perl tools/cpanm Class::MixinFactory

