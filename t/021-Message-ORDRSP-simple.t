#!/usr/bin/perl
#

use strict; use warnings;

use Test::More tests => 6;

BEGIN {
    use_ok('Data::Dumper');
    use_ok('Business::EDI');
    use_ok('Business::EDI::Test', qw/ordrsp_data/);
}

use vars qw/%code_hash $perl/;

my $debug = $Business::EDI::debug = @ARGV ? shift : 0;

my $edi = Business::EDI->new;

sub parse_ordrsp {
    my ($top_nodes) = @_;
    my $ordrsp;
    ok($ordrsp = $edi->detect_version($top_nodes), "EDI object via \$edi->detect_version");
    $debug and print Dumper $ordrsp;
}

ok($perl = ordrsp_data(), "DATA handle read and decode" );
$perl or die "DATA handle not read and decoded successfully";

$Data::Dumper::Indent = 1;

foreach my $part (shift @{$perl->{body}}) { # just do the first one
    foreach my $key (keys %$part) {
        next unless ok($key eq 'ORDRSP', "EDI interchange message type == ORDRSP");
        parse_ordrsp($part->{$key});
    }
}

note("done");

