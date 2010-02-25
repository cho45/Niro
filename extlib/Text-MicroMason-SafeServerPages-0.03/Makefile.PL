use inc::Module::Install;
name 'Text-MicroMason-SafeServerPages';
all_from 'lib/Text/MicroMason/SafeServerPages.pm';

requires $_ for (qw/Text::MicroMason/);

build_requires 'Test::More';
build_requires 'Test::Base';
build_requires 'YAML';

use_test_base;
auto_include;
WriteAll;
