#!/usr/bin/perl -w

use strict;
use Test::More tests => 24;

use_ok 'Text::MicroMason';

ok my $m = Text::MicroMason->new( -HTMLTemplate, template_root => 'samples', 'debug' => 0 );

######################################################################

# test a simple template
ok my $template = $m->new(filename => 'simple.tmpl');

ok $template->param( 'ADJECTIVE', 'very' );
ok my $output = $template->output();
unlike $output, qr/ADJECTIVE/;
is $template->param('ADJECTIVE'), 'very';

######################################################################

# test a simple loop template
ok $template = $m->new( filename => 'loop-simple.tmpl' );

ok $template->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );
ok $output = $template->output();
unlike $output, qr/ADJECTIVE_LOOP/;
like $output, qr/really.*very/s;

######################################################################

# test a loop template with context
ok $template = $m->new( filename => 'loop-context.tmpl', loop_context_vars => 1 );

ok $template->param('ADJECTIVE_LOOP', [ { ADJECTIVE => 'really' }, { ADJECTIVE => 'very' } ] );
ok $output = $template->output();
unlike $output, qr/ADJECTIVE_LOOP/;
like $output, qr/really.*very/s;

######################################################################

# test a simple if template
ok $template = $m->new( filename => 'if.tmpl' );
ok $output = $template->output();
unlike $output, qr/INSIDE/;

# test a simple if template
ok $template = $m->new( filename => 'if.tmpl' );
ok $template->param(BOOL => 1);
ok $output = $template->output();
like $output, qr/INSIDE/;

######################################################################
