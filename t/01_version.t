use Test::Most;

my @cases = (
    { first => "0.00", step => 0.01, wish => "0.01" },
    { first => "0.01", step => 0.01, wish => "0.02" },
    { first => "0.09", step => 0.01, wish => "0.10" },
    { first => "0.10", step => 0.01, wish => "0.11" },
    { first => "0.99", step => 0.01, wish => "1.00" },
    { first => "1.00", step => 0.01, wish => "1.01" },
);

plan tests => scalar @cases;

foreach my $case_ref ( @cases ) {
    my $version = sprintf "%.2f", $case_ref->{step} + $case_ref->{first};
    is( $version, $case_ref->{wish} );
}

