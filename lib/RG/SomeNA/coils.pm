package RG::SomeNA::coils;

use strict;
use feature qw(say);
use Carp;
use Data::Dumper;
use RG::SomeNA::Converter qw(sec_features acc_norm acc_features);

sub new {
    my ($class, $file) = @_;

    my $self = {"frame-14" => [],
                "prob-14"  => []};

    bless $self, $class;
    $self->parse($file);
    return $self;
}

my %letter2profile = (
    a => [1, 0, 0, 0, 0, 0, 0],
    b => [0, 1, 0, 0, 0, 0, 0],
    c => [0, 0, 1, 0, 0, 0, 0],
    d => [0, 0, 0, 1, 0, 0, 0],
    e => [0, 0, 0, 0, 1, 0, 0],
    f => [0, 0, 0, 0, 0, 1, 0],
    g => [0, 0, 0, 0, 0, 0, 1],
    x => [0, 0, 0, 0, 0, 0, 0],
);

sub parse {
    my ($self, $file) = @_;

    open FH, $file or croak "Could not open $file\n";
    while (my $line = <FH>) {
        chomp $line;
        if ($line =~ m/^frame-14/) {
            my ($dump, $seq) = split /\s+/, $line;
            my @split = split //, $seq;
            push @{$self->{"frame-14"}}, @split;
        }
        elsif ($line =~ m/^prob-14/) {
            my ($dump, $seq) = split /\s+/, $line;
            my @split = split //, $seq;
            foreach my $prob (@split) {
                my $prob2 = 0;
                if ($prob ne "-") {
                    $prob2 = $prob / 10;
                }
                push @{$self->{"prob-14"}}, $prob2;
            }
        }
    }
    close FH;
}

sub frame_14_7state {
    my ($self) = @_;

    my @result;
    my @frame_14 = @{$self->{"frame-14"}};
    foreach my $frame (@frame_14) {
        push @result, $letter2profile{$frame};
    }

    return @result;
}

sub prob_14 {
    my $self = shift;
    return @{$self->{"prob-14"}};
}

1;

