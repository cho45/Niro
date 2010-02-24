#!perl -Imodules/Plack/lib modules/Plack/scripts/plackup -app 
use strict;
use warnings;
use utf8;
use lib glob 'modules/*/lib';

use UNIVERSAL::require;
use Plack::Builder;
use Path::Class;
use File::Basename qw(dirname);

use Niro;

my $handler = \&Niro::run;

builder {
    enable "Plack::Middleware::Static",
        path => qr{^/(images|css|js)/}, root => dirname(__FILE__) . '/../static/';
    $handler;
};

