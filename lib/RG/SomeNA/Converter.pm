package RG::SomeNA::Converter;
use strict;
use feature qw(say);
use Carp;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(aa aa_features sec_features acc_norm acc_features normalize);


my $aa_features = {    
    'A'  =>  {'number' => 0, 'mass' => 0.109,    'volume' => 0.170,    'hydrophobicity' => 0.700,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 0},
    'R'  =>  {'number' => 1, 'mass' => 0.767,    'volume' => 0.676,    'hydrophobicity' => 0.000,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 1,      'polarity' => 0},    
    'N'  =>  {'number' => 2, 'mass' => 0.442,    'volume' => 0.322,    'hydrophobicity' => 0.111,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 1},
    'D'  =>  {'number' => 3, 'mass' => 0.450,    'volume' => 0.304,    'hydrophobicity' => 0.111,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0,      'polarity' => 1},
    'C'  =>  {'number' => 4, 'mass' => 0.357,    'volume' => 0.289,    'hydrophobicity' => 0.778,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 0},
    'Q'  =>  {'number' => 5, 'mass' => 0.550,    'volume' => 0.499,    'hydrophobicity' => 0.111,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 1},
    'E'  =>  {'number' => 6, 'mass' => 0.558,    'volume' => 0.467,    'hydrophobicity' => 0.111,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0,      'polarity' => 1},
    'G'  =>  {'number' => 7, 'mass' => 0.000,    'volume' => 0.000,    'hydrophobicity' => 0.456,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 0},
    'H'  =>  {'number' => 8, 'mass' => 0.620,    'volume' => 0.555,    'hydrophobicity' => 0.144,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 1,      'polarity' => 1},
    'I'  =>  {'number' => 9, 'mass' => 0.434,    'volume' => 0.636,    'hydrophobicity' => 1.000,    'cbeta' => 1,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 0},
    'L'  =>  {'number' => 10, 'mass' => 0.434,    'volume' => 0.636,    'hydrophobicity' => 0.922,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 0},
    'K'  =>  {'number' => 11, 'mass' => 0.550,    'volume' => 0.647,    'hydrophobicity' => 0.067,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 1,      'polarity' => 1},
    'M'  =>  {'number' => 12, 'mass' => 0.574,    'volume' => 0.613,    'hydrophobicity' => 0.711,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 0},
    'F'  =>  {'number' => 13, 'mass' => 0.698,    'volume' => 0.774,    'hydrophobicity' => 0.811,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 0},
    'P'  =>  {'number' => 14, 'mass' => 0.310,    'volume' => 0.314,    'hydrophobicity' => 0.322,    'cbeta' => 0,  'hbreaker' => 1,   'charge' => 0.5,    'polarity' => 0},
    'S'  =>  {'number' => 15, 'mass' => 0.233,    'volume' => 0.172,    'hydrophobicity' => 0.411,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 1},
    'T'  =>  {'number' => 16, 'mass' => 0.341,    'volume' => 0.334,    'hydrophobicity' => 0.422,    'cbeta' => 1,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 1},
    'W'  =>  {'number' => 17, 'mass' => 1.000,    'volume' => 1.000,    'hydrophobicity' => 0.400,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 0},
    'Y'  =>  {'number' => 18, 'mass' => 0.822,    'volume' => 0.796,    'hydrophobicity' => 0.356,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 1},
    'V'  =>  {'number' => 19, 'mass' => 0.326,    'volume' => 0.476,    'hydrophobicity' => 0.967,    'cbeta' => 1,  'hbreaker' => 0,   'charge' => 0.5,    'polarity' => 0},
    'X'  =>  {'number' => 20, 'mass' => 0,    'volume' => 0,    'hydrophobicity' => 0,    'cbeta' => 0,  'hbreaker' => 0,   'charge' => 0,    'polarity' => 0},
};
sub aa_features {
    my ($in, $out) = @_;
    return $aa_features->{$in}{$out};
}

my $sec_features = {
    H => { number => 0, oneletter   => 'H' },
    G => { number => 0, oneletter   => 'H' },
    I => { number => 0, oneletter   => 'H' },
    E => { number => 1, oneletter   => 'E' },
    B => { number => 1, oneletter   => 'E' },
    L => { number => 2, oneletter   => 'L' },
    S => { number => 2, oneletter   => 'L' },
    T => { number => 2, oneletter   => 'L' },
    '' => { number => 2, oneletter   => 'L' },
    ' ' => { number => 2, oneletter   => 'L' }
};
sub sec_features {
    my ($in, $out) = @_;
    return $sec_features->{$in}{$out};
}

my $acc_norm = {
    A => 106,  
    B => 160,         # D or N
    C => 135,  
    D => 163, 
    E => 194,
    F => 197, 
    G => 84, 
    H => 184,
    I => 169, 
    K => 205, 
    L => 164,
    M => 188, 
    N => 157, 
    P => 136,
    Q => 198, 
    R => 248, 
    S => 130,
    T => 142, 
    V => 142, 
    W => 227,
    X => 180,         # undetermined (deliberate)
    Y => 222, 
    Z => 196,         # E or Q
    max=>248
};
sub acc_norm {
    my ($in) = @_;
    return $acc_norm->{$in};
}

my $acc_features = {
    b => { two => 0, three   => 0 },
    i => { two => 0, three   => 1 },
    e => { two => 1, three   => 2 },
};
sub acc_features {
    my ($in, $out) = @_;
    return $acc_features->{$in}{$out};
}

my $aa = {
    A => 1,  
    C => 1,  
    D => 1, 
    E => 1,
    F => 1, 
    G => 1, 
    H => 1,
    I => 1, 
    K => 1, 
    L => 1,
    M => 1, 
    N => 1, 
    P => 1,
    Q => 1, 
    R => 1, 
    S => 1,
    T => 1, 
    V => 1, 
    W => 1,
    Y => 1,
    X => 1,
};
sub aa {
    my ($in) = @_;
    return $aa->{$in};
}

sub normalize {
    my $x = shift;
    my $t = shift || 0;
    return 1.0 / (1.0 + exp(-($x - $t)));
}

1;
