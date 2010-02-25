#!perl

use inc::Module::Install;

name 'HTTP-Body';
all_from 'lib/HTTP/Body.pm';

requires 'Carp';
requires 'File::Temp' => '0.14';
requires 'HTTP::Headers';
requires 'IO::File' => '1.14';

test_requires 'Test::More' => '0.86';
test_requires 'Test::Deep';

WriteAll;
