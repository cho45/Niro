#!/bin/sh

script=`readlink -f $0`
root=`dirname $script`/..

cd $root
echo Install deps to $root

perl tools/cpanm -lextlib --notest parent
perl tools/cpanm -lextlib --notest Try::Tiny
perl tools/cpanm -lextlib --notest Devel::StackTrace
perl tools/cpanm -lextlib --notest Devel::StackTrace::AsHTML
perl tools/cpanm -lextlib --notest Path::Class
perl tools/cpanm -lextlib --notest Exporter::Lite
perl tools/cpanm -lextlib --notest HTTP::Body
perl tools/cpanm -lextlib --notest Config::Tiny
perl tools/cpanm -lextlib --notest DateTime::Format::Builder
perl tools/cpanm -lextlib --notest DateTime::Format::SQLite
perl tools/cpanm -lextlib --notest Text::MicroMason
perl tools/cpanm -lextlib --notest Text::MicroMason::SafeServerPages
perl tools/cpanm -lextlib --notest Class::Factory::Util
perl tools/cpanm -lextlib --notest Class::MixinFactory
perl tools/cpanm -lextlib --notest JSON
perl tools/cpanm -lextlib --notest List::MoreUtils
perl tools/cpanm -lextlib --notest Cache::FileCache
perl tools/cpanm -lextlib --notest URI::Escape

