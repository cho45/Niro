#!perl -Imodules/Plack/lib modules/Plack/scripts/plackup -app 
#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use lib glob 'modules/*/lib';

use UNIVERSAL::require;

use Niro;

\&Niro::run;
