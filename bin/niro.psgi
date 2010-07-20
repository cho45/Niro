#!perl -Imodules/Plack/lib modules/Plack/scripts/plackup -r -app 
use strict;
use warnings;
use utf8;
use lib glob 'modules/*/lib';
use lib glob 'extlib/*/lib';

use UNIVERSAL::require;
use Plack::Builder;
use Path::Class;
use File::Basename qw(dirname);

use Niro;

my $handler = \&Niro::run;

builder {
    enable "Plack::Middleware::Static",
        path => qr{^//?static/}, root => dirname(__FILE__) . '/../';
    $handler;
};

