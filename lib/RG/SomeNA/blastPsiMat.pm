package RG::SomeNA::blastPsiMat;

use strict;
use warnings;
use feature qw(say);
use Carp;
use RG::SomeNA::Converter qw(normalize);

sub new {
    my ($class, $file) = @_;

    my $self = {
        raw  => [],
        normalized => [],
        percentage   => [],
        info       => [],
        weight     => [],
        res         => [],
    };

    bless $self, $class;
    $self->parse($file);
    return $self;
}

sub parse {
    my ($self, $file) = @_;

    open PSSM, $file or croak "Could not open $self->{file} ...\n";
    my @pssm_cont = grep /^\s*\d+/, (<PSSM>);
    chomp @pssm_cont;
    close PSSM;
    
    my $length = $self->{_length} = scalar @pssm_cont;

    foreach my $line (@pssm_cont) {
        $line =~ s/^\s+//;
        my @split = split /\s+/, $line;

        my $res = $split[1];
        push @{$self->{res}}, $res;
        my @raws = @split[2..21];
        my @norms = map {normalize($_)} @raws;
        push @{$self->{raw}}, \@raws;
        push @{$self->{normalized}}, \@norms;
        my @pcs = @split[22 .. 41];
        my @pc_norms = map {$_ / 100} @pcs;
        push @{$self->{percentage}}, \@pc_norms;
        push @{$self->{info}}, (normalize($split[42]));
        if ($split[43] eq "inf") {
            push @{$self->{weight}}, 0;
        }
        else {
            push @{$self->{weight}}, (normalize($split[43]));
        }
    }
}

sub res {
    my $self = shift;
    return @{$self->{res}};
}

sub raw {
    my $self = shift;
    return @{$self->{raw}};
}

sub normalized {
    my $self = shift;
    return @{$self->{normalized}};
}

sub percentage {
    my $self = shift;
    return @{$self->{percentage}};
}

sub info {
    my $self = shift;
    return @{$self->{info}};
}

sub weight {
    my $self = shift;
    return @{$self->{weight}};
}

1;
