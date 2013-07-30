package RG::SomeNA::isis;

use strict;
use feature qw(say);
use Carp;
use Data::Dumper;
use RG::SomeNA::Converter qw(sec_features acc_norm acc_features);

sub new {
    my ($class, $file) = @_;

    my $self = {binding => [],
                raw     => []};

    bless $self, $class;
    $self->parse($file);
    return $self;
}

sub parse {
    my ($self, $file) = @_;

    open FH, $file or croak "Could not open $file\n";
    while (my $line = <FH>) {
        chomp $line;
        if (length $line > 0) {
            my @split = split /\s+/, $line;
            if (scalar @split == 3) {
                my $raw = $split[2] / 2 + 50;
                push @{$self->{raw}}, $split[2];
            }
            elsif ($line =~ m/^>/) {

            }
            else {
                my $binding_raw = <FH>;
                chomp $binding_raw;
                my @split = split //, $binding_raw;
                foreach my $s (@split) {
                    if ($s eq "-") {
                        push @{$self->{binding}}, 0;
                    }
                    else {
                        push @{$self->{binding}}, 1;
                    }
                }
            }
        }
    }
    close FH;
}

sub bind_2state {
    my ($self) = @_;

    my @result;
    foreach my $r (@{$self->{binding}}) {
        if ($r == 0) {
            push @result, [0, 1];
        }
        else {
            push @result, [1, 0];
        }
    }

    return @result;
}

sub raw {
    my ($self) = @_;

    my @result;
    foreach my $raw (@{$self->{raw}}) {
        push @result, (($raw / 2 + 50) / 100);
    }
    return @result;
}

1;

