#!/usr/bin/env perl
use strict;

use lib glob 'modules/*/lib';
use lib glob 'extlib/lib/perl5';
use lib 'lib';

use Plack::Runner;

my $runner = Plack::Runner->new;
$runner->parse_options('-app', 'bin/niro.psgi');
$runner->run;

