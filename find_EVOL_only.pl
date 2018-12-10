use strict;
use warnings;
my $hdr = <>;
print $hdr;
while(<>) {
    my @row = split;
    # last 2 are our genotypes of interest
    my $evolAllele = pop @row;
    my $WTAllele = pop @row;
    $evolAllele =~ s/\///;
    $WTAllele =~ s/\///;
    my $refAllele = pop @row;
    next if( $evolAllele eq $WTAllele); # assume this is Af293 
    next if ( $evolAllele eq '.');
    next if $evolAllele eq $refAllele;
    next if length($WTAllele) > 2;
    print;
}
