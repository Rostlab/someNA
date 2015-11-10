package RG::SomeNA::SomeNA;

use strict;
use feature qw(say);
use Carp;
use Data::Dumper;

sub new {
    my ($class, %args) = @_;

    my $self = \%args;

    my $chain_length = $self->{parsers}{fasta}->length_int;
    $self->{info}{length} = $chain_length;
    $self->{info}{group_window} = 5;

    bless $self, $class;
    return $self;
}

sub predict {
    my $self = shift;

    foreach my $xna (keys %{$self->{models}}) {
        foreach my $type (keys %{$self->{models}{$xna}}) {
            foreach my $fold (keys %{$self->{models}{$xna}{$type}}) {
                my $predictions;
                foreach my $nr (keys %{$self->{models}{$xna}{$type}{$fold}}) {
                    push @$predictions, ($self->predict_single($xna, $type, $fold, $nr));
                }

                foreach my $i (1 .. scalar @$predictions - 1) {
                    foreach my $j (0 .. scalar @{$predictions->[0]} - 1) {
                        $predictions->[0][$j] += $predictions->[$i][$j];
                    }
                }

                my $threshold = $self->{thresholds}{$xna}{$type}{$fold};
                my @prediction_binary;
                foreach my $j (0 .. scalar @{$predictions->[0]} - 1) {
                    $predictions->[0][$j] /= scalar @$predictions;

                    if ($predictions->[0][$j] >= $threshold) {
                        push @prediction_binary, 1;
                    }
                    else {
                        push @prediction_binary, 0;
                    }
                }

                $self->{predictions}{$xna}{$type}{$fold} = $predictions->[0];
                $self->{predictions_binary}{$xna}{$type}{$fold} = \@prediction_binary;

                # Protein score calculation
                my $pscore = 0;
                my $group_window = $self->{info}{group_window};
                foreach my $i (0 .. scalar @prediction_binary - 1) {
                    my $win_start = $i - (($group_window - 1) / 2);
                    my $win_end = $i + (($group_window - 1) / 2);

                    if ($win_start < 0) {
                        $win_start = 0;
                    }
                    if ($win_end >= scalar @prediction_binary) {
                        $win_end = scalar @prediction_binary - 1;
                    }

                    my $hits = 0;
                    foreach my $j ($win_start .. $win_end) {
                        if ($prediction_binary[$j] > 0) {
                            $hits++;
                        }
                    }
                    $pscore += $hits;
                }

                my $pthreshold = $self->{thresholds}{$xna}{prot}{$fold};
                $self->{predictions_pscore}{$xna}{$type}{$fold} = $pscore;
                $self->{predictions_pscore_norm}{$xna}{$type}{$fold} = $pscore - $pthreshold;

                if ($pscore >= $pthreshold) {
                    $self->{predictions_pscore_binary}{$xna}{$type}{$fold} = 1;
                }
                else {
                    $self->{predictions_pscore_binary}{$xna}{$type}{$fold} = 0;
                }
            }
        }
    }

    my $length = $self->{info}{length};

    my $fold_count_glob = 0;
    # Residue based
    foreach my $xna (keys %{$self->{models}}) {
        my @prediction_avg;
        my @prediction_jury;

        foreach my $i (1 .. $length) {
            push @prediction_avg, 0;
            push @prediction_jury, 0;
        }

        my $fold_count = 0;
        foreach my $fold (keys %{$self->{models}{$xna}{only}}) {
            my $prediction = $self->{predictions}{$xna}{only}{$fold};
            my $prediction_binary = $self->{predictions_binary}{$xna}{only}{$fold};

            foreach my $i (0 .. $length - 1) {
                $prediction_avg[$i] += $prediction->[$i];
                $prediction_jury[$i] += $prediction_binary->[$i];
            }
            
            $fold_count++;
        }

        foreach my $i (0 .. $length - 1) {
            $prediction_avg[$i] /= $fold_count;
            $prediction_jury[$i] /= $fold_count;
        }

        $self->{predictions_avg}{$xna}{only} = \@prediction_avg;
        $self->{predictions_jury}{$xna}{only} = \@prediction_jury;

        $fold_count_glob = $fold_count;
    }


    # Protein based
    my $fold_count = 0;
    my $dna_jury = 0;
    my $rna_jury = 0;
    my $xna_jury = 0;
    my $dna_comb_jury = 0;
    my $rna_comb_jury = 0;
    foreach my $fold (keys %{$self->{models}{xna}{all}}) {
        my $dna_pred = $self->{predictions_pscore_norm}{dna}{all}{$fold};
        my $rna_pred = $self->{predictions_pscore_norm}{rna}{all}{$fold};
        my $xna_pred = $self->{predictions_pscore_norm}{xna}{all}{$fold};

        if ($dna_pred >= 0) {
            $dna_jury++;

        }
        if ($rna_pred >= 0) {
            $rna_jury++;

        }
        if ($xna_pred >= 0) {
            $xna_jury++;
        }

        if ($xna_pred >= 0 && $dna_pred >= 0 && $dna_pred > $rna_pred) {
            $dna_comb_jury++;
        }
        if ($xna_pred >= 0 && $rna_pred >= 0 && $rna_pred > $dna_pred) {
            $rna_comb_jury++;
        }

        $fold_count++;
    }

    $dna_jury /= $fold_count;
    $rna_jury /= $fold_count;
    $xna_jury /= $fold_count;
    $dna_comb_jury /= $fold_count;
    $rna_comb_jury /= $fold_count;

    $self->{predictions_global}{dna_jury} = $dna_jury;
    $self->{predictions_global}{rna_jury} = $rna_jury;
    $self->{predictions_global}{xna_jury} = $xna_jury;
    $self->{predictions_global}{dna_comb_jury} = $dna_comb_jury;
    $self->{predictions_global}{rna_comb_jury} = $rna_comb_jury;
}

sub output_string {
    my $self = shift;

    my $out_string = "";

    $out_string .= "".(join "\n",
        "#############################################################",
        "# SomeNA - Prediction of DNA- and RNA-Binding Proteins",
        "#############################################################",
        "# Row Format",
        "#  The first column is the TYPE of the row",
        "#  #               : Comment",
        "#",
        "#  DNA_JURY        : DNA-binding single prediction",
        "#  RNA_JURY        : RNA-binding single prediction",
        "#  XNA_JURY        : XNA-binding single prediction",
        "#  DNA_COMB_JURY   : Combined DNA-binding prediction",
        "#                    (has XNA-binding as prequisite and excludes RNA-binding; very precise)",
        "#  RNA_COMB_JURY   : Combined RNA-binding prediction",
        "#                    (has XNA-binding as prequisite and excludes DNA-binding; very precise)",
        "#",
        "#  HEADER          : The header line for the PRP rows",
        "#",
        "#  PRP             : Per residue predictions",
        "#############################################################",
        "# PRP Column Format",
        "#  NO              : Amino acid position",
        "#  RES             : Amino acid one-letter code",
        "#  DNA_AVG         : Average of direct scores of the DNA models",
        "#  DNA_JURY        : Fraction of models that predicted DNA-binding",
        "#  RNA_AVG         : Average of direct scores of the RNA models",
        "#  RNA_JURY        : Fraction of models that predicted RNA-binding",
        "#  XNA_AVG         : Average of direct scores of the XNA models",
        "#  XNA_JURY        : Fraction of models that predicted XNA-binding",
        "#############################################################",
        "# Notes",
        "#  The _JURY suffixed rows and columns can be interpreted as",
        "#  positive/yes prediction if they show a value above 0.5,",
        "#  meaning that the majority of network models predicted",
        "#  the positive class",
        "#############################################################",
    )."\n";

    $out_string .= "DNA_JURY\t".(sprintf "%.2f", $self->{predictions_global}{dna_jury})."\n";
    $out_string .= "RNA_JURY\t".(sprintf "%.2f", $self->{predictions_global}{rna_jury})."\n";
    $out_string .= "XNA_JURY\t".(sprintf "%.2f", $self->{predictions_global}{xna_jury})."\n";
    $out_string .= "DNA_COMB_JURY\t".(sprintf "%.2f", $self->{predictions_global}{dna_comb_jury})."\n";
    $out_string .= "RNA_COMB_JURY\t".(sprintf "%.2f", $self->{predictions_global}{rna_comb_jury})."\n";

    $out_string .= "HEADER\tNO\tRES\tDNA_AVG\tDNA_JURY\tRNA_AVG\tRNA_JURY\tXNA_AVG\tXNA_JURY\n";

    my @res = $self->{parsers}{fasta}->residue;
    my $dna_avg = $self->{predictions_avg}{dna}{only};
    my $dna_jury = $self->{predictions_jury}{dna}{only};
    my $rna_avg = $self->{predictions_avg}{rna}{only};
    my $rna_jury = $self->{predictions_jury}{rna}{only};
    my $xna_avg = $self->{predictions_avg}{xna}{only};
    my $xna_jury = $self->{predictions_jury}{xna}{only};

    foreach my $i (0 .. $self->{info}{length} - 1) {
        my $no = $i + 1;
        my $res = $res[$i];


        $out_string .= "".(join "\t", "PRP", $no, $res, (map {sprintf "%.2f", $_} $dna_avg->[$i], $dna_jury->[$i], $rna_avg->[$i], $rna_jury->[$i], $xna_avg->[$i], $xna_jury->[$i]))."\n";
    }

    return $out_string;
}

sub predict_single {
    my ($self, $xna, $type, $fold, $nr) = @_;

    my $chain_length = $self->{info}{length};
    my $features = $self->{features}{$xna}{$type}{$fold}{$nr};

    my $inputs;
    foreach (1 .. $chain_length) {
        push @$inputs, [];
    }

    foreach my $f (@$features) {
        my ($source, $feature, $window, $filter) = @$f;
        my @current_data;
        my @current_data_tmp;
        @current_data_tmp = $self->{parsers}{$source}->$feature;

        foreach my $center (0 .. $chain_length - 1) {
                my $filter_from = $center - ($filter - 1) / 2;
                my $filter_to = $center + ($filter - 1) / 2;
                my $filter_value = 0;
                my $filter_length = 0;

                my @raw_center;
                if (ref $current_data_tmp[$center]) {
                    push @raw_center, (map {0} @{$current_data_tmp[$center]});
                }
                else {
                    push @raw_center, 0;
                }

                foreach my $filter_pos ($filter_from .. $filter_to) {
                    next if ($filter_pos < 0 || $filter_pos >= $chain_length);

                    if (ref $current_data_tmp[$filter_pos]) {
                        foreach my $i (0 .. scalar @{$current_data_tmp[$filter_pos]} - 1) {
                            $raw_center[$i] += $current_data_tmp[$filter_pos]->[$i];
                        }
                    }
                    else {
                        $raw_center[0] += $current_data_tmp[$filter_pos];
                    }

                    $filter_length++;
                }

                foreach my $c (@raw_center) {
                    $c /= $filter_length;
                }

                if (scalar @raw_center == 1) {
                    push @current_data, $raw_center[0];
                }
                else {
                    push @current_data, \@raw_center;
                }
        }

        foreach my $center (0 .. $chain_length - 1) {
            my $win_start = $center - ($window - 1) / 2;
            my $win_end = $center + ($window - 1) / 2;

            foreach my $iter ($win_start .. $win_end) {

                if ($iter < 0 || $iter >= $chain_length) {
                    if (ref $current_data[$center]) {
                        push @{$inputs->[$center]}, (map {0} @{$current_data[$center]});
                    }
                    else {
                        push @{$inputs->[$center]}, 0;
                    }
                }
                else {
                    if (ref $current_data[$iter]) {
                        push @{$inputs->[$center]}, @{$current_data[$iter]};
                    }
                    else {
                        push @{$inputs->[$center]}, $current_data[$iter];
                    }
                }
            }
        }
    }

    my $outputs;
    my $nn = $self->{models}{$xna}{$type}{$fold}{$nr};
    foreach my $input (@$inputs) {
        my $out_tmp = $nn->run($input);
        push @$outputs, ($out_tmp->[0] - $out_tmp->[1]);
    }

    return $outputs;
}

1;
