use 5.006;

use strict;
use warnings;

use Module::Build;

my $build =
    Module::Build->new( module_name => 'Devel::StackTrace',
                        license     => 'perl',
                        requires    => { 'File::Spec'   => '0',
                                         'Scalar::Util' => '0',
                                         'Test::More'   => '0.46',
                                         'perl'         => '5.006',
                                       },
                        sign        => 1,
                        create_makefile_pl => 'traditional',
                        create_readme      => 1,
                      );

$build->create_build_script;
