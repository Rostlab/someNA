#!/usr/bin/perl
use warnings;
use strict;
use Carp;
use Getopt::Long;
use Pod::Usage;
use File::Spec;
use Data::Dumper;

use AI::FANN;

use RG::SomeNA::SomeNA;
use RG::SomeNA::blastPsiMat;
use RG::SomeNA::fasta;
use RG::SomeNA::profbval;
use RG::SomeNA::isis;
use RG::SomeNA::reprof;
use RG::SomeNA::coils;

my $model_dir = "../share/somena/";
my $input_dir;# = "../data/input/dna_1am9:C";
my $out_file;

GetOptions(
    'model=s'    =>  \$model_dir,
    'input=s'   =>  \$input_dir,
    'out=s'     =>  \$out_file,
);

sub print_usage {
    print "".(join "\n", 
        "",
        "SomeNA - Prediction of DNA- and RNA-Binding Proteins",
        "",
        "Usage:",
        "\tsomena.pl -m MODEL_DIR -i INPUT_DIR -o OUT_FILE",
        "",
        "\t-m MODEL_DIR",
        "\t\tDirectory containing the neural network models, the feature",
        "\t\tconstellation and threshold files.",
        "",
        "\t-i INPUT_DIR",
        "\t\tDirectory containing the PredictProtein output files with",
        "\t\tthe suffixes .fasta .blastPsiMat .profbval .isis .reprof",
        "\t\tand .coils.",
        "",
        "\t-o OUT_FILE",
        "\t\tOutput file. If not specified, the output is written to STDOUT.",
        "",
        "\tThe output format is self-explanatory.",
        "",
    )."\n";
}

if (!defined $model_dir || !-e $model_dir) {
    print_usage();
    die "No model file directory defined\n";
}
if (!defined $input_dir || !-e $input_dir) {
    print_usage();
    die "No input file directory defined\n";
}

my %params;
my @files2load = qw(blastPsiMat fasta profbval isis reprof coils);

my @model_dir_content = glob "$model_dir/*";
my @input_dir_content = glob "$input_dir/*";

### SUBS ###
sub file_base_split {
    my $file = shift;

    my @split_raw = split /\./, $file;
    return (split /_/, $split_raw[0]);
}

sub parse_feature_file {
    my $file = shift;
    my $inputs = [];

    open FH, $file or croak "fh error\n";
    while (my $line = <FH>) {
        chomp $line;
        my ($type, $format, $value, $window, $filter) = split /\s+/, $line;

        if ($type eq "input") {
            push @$inputs, [$format, $value, $window, $filter // 1];
        }
    }
    close FH;

    return $inputs;
}

sub parse_threshold_file {
    my $file = shift;

    my $thresholds;

    open TH, $file or croak "*** Could not open $file - $!\n";
    while (my $line = <TH>) {
        chomp $line;
        my @split = split /\s+/, $line;
        if (scalar @split >= 2) {
            my ($xna, $type, $fold) = file_base_split $split[0];

            $thresholds->{$xna}{$type}{$fold} = $split[1];
        }
    }
    close TH;

    return $thresholds;
}
### END SUBS ###

foreach my $content (@model_dir_content) {
    my ($v, $d, $file) = File::Spec->splitpath($content);

    if ($file =~ m/^thresholds$/) {
        my $thresholds = parse_threshold_file $content;

        $params{thresholds} = $thresholds;

    }
    elsif ($file =~ m/\.model/) {
        my ($xna, $type, $fold, $nr) = file_base_split $file;

        my $ann = AI::FANN->new_from_file($content);
        $params{models}->{$xna}{$type}{$fold}{$nr} = $ann;
    }
    elsif ($file =~ m/\.features/) {
        my ($xna, $type, $fold, $nr) = file_base_split $file;

        my $features = parse_feature_file $content;

        $params{features}->{$xna}{$type}{$fold}{$nr} = $features;
    }
}

foreach my $file2load (@files2load) {
    my $module = "SomeNA::$file2load";

    my ($file) = grep /\.$file2load$/, @input_dir_content;

    if (!defined $file) {
        print_usage();
        die "$file2load input file was not found\n";
    }

    my $parser = $module->new($file);

    $params{parsers}->{$file2load} = $parser;
}

my $somena = SomeNA::SomeNA->new(%params);

$somena->predict;

my $out_string = $somena->output_string;

if (defined $out_file) {
    open OUT, ">$out_file" or croak "*** Could not open $out_file - $!\n";
    print OUT $out_string;
    close OUT;
}
else {
    print $out_string;
}
