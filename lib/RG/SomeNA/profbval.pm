package RG::SomeNA::profbval;

use strict;
use feature qw(say);
use Carp;
use Data::Dumper;
use RG::SomeNA::Converter qw(sec_features acc_norm acc_features);
use POSIX qw(floor);

sub new {
    my ($class, $file) = @_;

    my $self = {flexible    => [],
                rigid       => [],
                RI          => []};

    bless $self, $class;
    $self->parse($file);
    return $self;
}

sub parse {
    my ($self, $file) = @_;

    my $header_read = 0;
    open FH, $file or croak "Could not open $file\n";
    while (my $line = <FH>) {
        if ($line =~ m/\* out vec:/) {
            $header_read = 1;
        }
        elsif ($header_read) {
            chomp $line;
            $line =~ s/^\s+//g;
            $line =~ s/\s+$//g;
            my ($nr, $flexible, $rigid) = split /\s+/, $line;
            push @{$self->{flexible}}, ($flexible / 100);
            push @{$self->{rigid}}, ($rigid / 100);
            my $ri = (floor(abs($flexible - $rigid) / 10)) / 10;
            push @{$self->{RI}}, $ri;
        }
    }
    close FH;
}

sub OtFR {
    my $self = shift;
    
    my @flexible = @{$self->{flexible}};
    my @rigid = @{$self->{rigid}};

    my @result;
    foreach my $pos (0 .. scalar @flexible - 1) {
        push @result, [$flexible[$pos], $rigid[$pos]];
    }

    return @result;
}

sub RI {
    my $self = shift;
    
    return @{$self->{RI}};
}

1;
