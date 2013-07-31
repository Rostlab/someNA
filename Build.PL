use warnings;
use strict;
use Module::Build;

my $build = Module::Build->new(
    module_name     => 'RG::SomeNA',
    license         => 'gpl',                                                                                                                              
    dist_name       => 'somena',
    dist_version    => '1.0.1-1',
    dist_author     => ['Peter Hoenigschmid <hoenigschmid@rostlab.org>', 'Burkhard Rost'],
    dist_abstract   => 'protein DNA/RNA binding predictor',
);
$build->create_build_script;
