package RG::SomeNA::reprof;

use strict;
use feature qw(say);
use Carp;
use Data::Dumper;
use RG::SomeNA::Converter qw(sec_features acc_norm acc_features);

sub new {
    my ($class, $file) = @_;

    my $self = {};

    bless $self, $class;
    $self->parse($file);
    return $self;
}

sub parse {
    my ($self, $file) = @_;

    my @header;
    my $header_read = 0;
    open FH, $file or croak "Could not open $file\n";
    while (my $line = <FH>) {
        if ($line !~ m/^#/) {
            chomp $line;
            my @split = split /\s+/, $line;
            if ($header_read) {
                my $iter = 0;
                foreach my $val (@split) {
                    push @{$self->{$header[$iter]}}, $val;

                    $iter++;
                }
            }
            else {
                push @header, @split;
                $header_read = 1;
            }
        }
    }
    close FH;
}

sub pHEL {
    my ($self) = @_;

    my @OtH = @{$self->{pH}};
    my @OtE = @{$self->{pE}};
    my @OtL = @{$self->{pL}};

    my @result;
    foreach my $pos (0 .. scalar @OtH - 1) {
        push @result, [($OtH[$pos] / 100), ($OtE[$pos] / 100), ($OtL[$pos] / 100)];
    }

    return @result;
}

sub OtHEL {
    my ($self) = @_;

    my @OtH = @{$self->{OtH}};
    my @OtE = @{$self->{OtE}};
    my @OtL = @{$self->{OtL}};

    my @result;
    foreach my $pos (0 .. scalar @OtH - 1) {
        push @result, [($OtH[$pos] / 100), ($OtE[$pos] / 100), ($OtL[$pos] / 100)];
    }

    return @result;
}

sub RI_S_raw{
    my ($self) = @_;

    return @{$self->{RI_S}};
}

sub RI_S {
    my ($self) = @_;

    my @RI_S = @{$self->{RI_S}};

    my @result;
    foreach my $ri_s (@RI_S) {
        push @result, ($ri_s / 10);
    }

    return @result;
}

sub RI_A {
    my ($self) = @_;

    my @RI_A = @{$self->{RI_A}};

    my @result;
    foreach my $ri_a (@RI_A) {
        push @result, ($ri_a / 10);
    }

    return @result;
}

sub Pbie {
    my $self = shift;

    my @result;
    foreach my $bie (@{$self->{Pbie}}) {
        if ($bie eq "b") {
            push @result, [1, 0, 0];
        }
        elsif ($bie eq "i") {
            push @result, [0, 1, 0];
        }
        elsif ($bie eq "e") {
            push @result, [0, 0, 1];
        }
        else {
            warn "Invalid 3state solvent accessibility detected\n";
        }
    }

    return @result;
}

sub OtACC {
    my ($self) = @_;

    my @Ot0 = @{$self->{Ot0}};
    my @Ot1 = @{$self->{Ot1}};
    my @Ot2 = @{$self->{Ot2}};
    my @Ot3 = @{$self->{Ot3}};
    my @Ot4 = @{$self->{Ot4}};
    my @Ot5 = @{$self->{Ot5}};
    my @Ot6 = @{$self->{Ot6}};
    my @Ot7 = @{$self->{Ot7}};
    my @Ot8 = @{$self->{Ot8}};
    my @Ot9 = @{$self->{Ot9}};

    my @result;
    foreach my $pos (0 .. scalar @Ot0 - 1) {
        push @result, [($Ot0[$pos] / 100), ($Ot1[$pos] / 100), ($Ot2[$pos] / 100), ($Ot3[$pos] / 100), ($Ot4[$pos] / 100), ($Ot5[$pos] / 100), ($Ot6[$pos] / 100), ($Ot7[$pos] / 100), ($Ot8[$pos] / 100), ($Ot9[$pos] / 100)];
    }

    return @result;
}

sub PHEL_3state {
    my ($self) = @_;

    my @result;
    foreach my $val (@{$self->{PHEL}}) {
        my $nr = sec_features($val, "number");
        my @raw = (0, 0, 0);
        $raw[$nr] = 1;
        push @result, \@raw;
    }

    return @result;
}

sub PHEL{
    my ($self) = @_;

    return @{$self->{PHEL}};
}

sub PREL_10state {
    my ($self) = @_;

    my @result;
    foreach my $val (@{$self->{PREL}}) {
        my $nr = int(sqrt $val);
        my @raw = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $raw[$nr] = 1;
        push @result, \@raw;
    }

    return @result;
}

sub Pbie_3state {
    my ($self) = @_;

    my @result;
    foreach my $val (@{$self->{Pbie}}) {
        my $nr = acc_features($val, "three");
        my @raw = (0, 0, 0);
        $raw[$nr] = 1;
        push @result, \@raw;
    }

    return @result;
}

sub Pbe_2state {
    my ($self) = @_;

    my @result;
    foreach my $val (@{$self->{Pbe}}) {
        my $nr = acc_features($val, "two");
        my @raw = (0, 0);
        $raw[$nr] = 1;
        push @result, \@raw;
    }

    return @result;
}

sub class_4state {
    my $self = shift;

    my $H = 0;
    my $E = 0;
    my $L = 0;

    foreach my $sec (@{$self->{PHEL}}) {
        if ($sec eq "H") {
            $H++;
        }
        elsif ($sec eq "E") {
            $E++;
        }
        elsif ($sec eq "L") {
            $L++;
        }
    }

    my $total = $H + $E + $L;

    $H /= $total;
    $E /= $total;
    $L /= $total;

    if ($H >= 0.45 && $E < 0.05) {
        return (1, 0, 0, 0);
    }
    elsif ($H < 0.05 && $E >= 0.45) {
        return (0, 1, 0, 0);
    }
    elsif ($H >= 0.3 && $E >= 0.2) {
        return (0, 0, 1, 1);
    }
    else {
        return (0, 0, 0, 1);
    }
}

1;
