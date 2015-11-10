package RG::SomeNA::fasta;

use strict;
use feature qw(say);
use Carp;
use Data::Dumper;
use RG::SomeNA::Converter qw(aa aa_features);


sub new {
    my ($class, $file) = @_;

    my $self = {
        data => [],
        header => undef,
        length => undef
    };

    bless $self, $class;
    $self->parse($file);
    return $self;
}

sub new_sequence {
    my ($class, $seq) = @_;

    chomp $seq;
    my @split = split //, $seq;
    my $self = {
        data => [@split],
        header => undef,
        length => scalar @split,
    };

    bless $self, $class;
    return $self;
}

sub parse {
    my ($self, $file) = @_;

    open FASTA, $file or croak "Could not open $file\n";
    while (my $line = <FASTA>) {
        chomp $line;
        if ($line =~ m/^>/) {
            $self->{header} = substr $line, 1;
        }
        else {
            $line =~ s/\s+//g;
            push @{$self->{data}}, (split //, $line);
        }
    }
    close FASTA;

    $self->{length} = scalar @{$self->{data}};
}

sub length_int {
    my $self = shift;
    return $self->{length};
}

sub header {
    my $self = shift;
    return $self->{header};
}

sub residue {
    my ($self, $id) = @_;

    my @residues = @{$self->{data}};
    return @residues;
}

sub position {
    my ($self, $id) = @_;

    my @positions = (1 .. $self->{length});

    return @positions;
}

sub relative_position {
    my ($self, $id) = @_;

    my @positions = (1 .. $self->{length});
    my $length = $self->{length};
    my @relative_positions = map {$_ / $length} @positions;

    return @relative_positions;
}

sub relative_position_reverse {
    my ($self, $id) = @_;

    my @positions = (1 .. scalar @{$self->{data}});
    my $length = $self->{length};
    my @relative_positions = map {1 - $_ / $length} @positions;

    return @relative_positions;
}

sub in_sequence_bit {
    my ($self, $id) = @_;

    my $length = $self->{length};
    my @result = map {1} (1 .. $length);

    return @result;
}

sub length {
    my ($self, $id) = @_;

    my $length = $self->{length};

    return map {$length} (1 .. $length);
}

sub distanceN {
    my ($self, $id) = @_;

    my $length = $self->{length};
    my @distances;
    foreach my $pre (0 .. $length - 1) {
        my @current = (0, 0, 0, 0);
        foreach my $i (1 .. 4) {
            if ($pre >= 2 ** ($i - 1) * 10) {
                $current[$i - 1] = 1;
            }
            else {
                my $r = ($pre - 2 ** ($i - 2) * 10) / (2 ** ($i - 1) * 10);
                $r = 0 if $r < 0;
                $current[$i - 1] = $r;
            }
        }
        push @distances, \@current;
    }

    return @distances;
}

sub distanceC {
    my ($self, $id) = @_;

    my $length = $self->{length};
    my @distances;
    foreach my $pre (1 .. $length) {
        my $post = $length - $pre;
        my @current = (0, 0, 0, 0);
        foreach my $i (1 .. 4) {
            if ($post >= 2 ** ($i - 1) * 10) {
                $current[$i - 1] = 1;
            }
            else {
                my $r = ($post - 2 ** ($i - 2) * 10) / (2 ** ($i - 1) * 10);
                $r = 0 if $r < 0;
                $current[$i - 1] = $r;
            }
        }
        push @distances, \@current;
    }

    return @distances;
}

sub length_4state {
    my ($self, $id) = @_;

    my $length = $self->{length};
    my @result = (0, 0, 0, 0);
    foreach my $i (1 .. 4) {
        if ($length >= 2 ** ($i - 1) * 60) {
            $result[$i - 1] = 1;
        }
        else {
            my $r = ($length - 2 ** ($i - 2) * 60) / (2 ** ($i - 1) * 60);
            $r = 0 if $r < 0;
            $result[$i - 1] = $r;
        }
    }

    return map {\@result} (1 .. $length);
}


sub profile {
    my ($self, $id) = @_;

    my @residues = @{$self->{data}};
    my @profiles;

    foreach my $residue (@residues) {
        carp "Invalid residue $residue\n" unless defined aa($residue);

        my @tmp_profile = map {0} (1 .. 20);
        my $array_pos = aa_features($residue, "number");
        if ($array_pos < scalar @tmp_profile) {
            $tmp_profile[$array_pos] = 1;
        }

        push @profiles, \@tmp_profile;
    }

    return @profiles;
}

sub aa_composition {
    my ($self, $id) = @_;

    my @residues = @{$self->{data}};
    my @composition = map {0} (0 .. 20);

    foreach my $residue (@residues) {
        if (! defined aa($residue)) {
            warn "changing $residue to X";
            $residue = 'X';
        }

        $composition[aa_features($residue, "number")]++;
    }

    my $length = $self->{length};
    foreach my $item (@composition) {
        $item /= $length;
    }

    return map {\@composition} (1 .. $length);
}

sub feature {
    my ($self, $id, $feature) = @_;

    my @residues = @{$self->{data}};
    my @result;

    foreach my $residue (@residues) {
        if (! defined aa($residue)) {
            warn "changing $residue to X";
            $residue = 'X';
        }

        push @result, aa_features($residue, $feature);
    }

    return @result;
}

sub mass {
    my ($self, $id) = @_;
    
    my @result = $self->feature($id, "mass");

    return @result;
}

sub volume {
    my ($self, $id) = @_;
    
    my @result = $self->feature($id, "volume");

    return @result;
}
sub hydrophobicity {
    my ($self, $id) = @_;
    
    my @result = $self->feature($id, "hydrophobicity");

    return @result;
}
sub cbeta {
    my ($self, $id) = @_;
    
    my @result = $self->feature($id, "cbeta");

    return @result;
}
sub hbreaker {
    my ($self, $id) = @_;
    
    my @result = $self->feature($id, "hbreaker");

    return @result;
}
sub charge {
    my ($self, $id) = @_;
    
    my @result = $self->feature($id, "charge");

    return @result;
}
sub polarity {
    my ($self, $id) = @_;
    
    my @result = $self->feature($id, "polarity");

    return @result;
}

1;
