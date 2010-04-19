#!/usr/bin/perl
#
# run this script with a true argument to get verbose output

use strict; use warnings;

use Test::More tests => 21;
use vars qw/$verbose $var1 $var2 $var3 $var4/;

BEGIN {
    use_ok('Data::Dumper');
    use_ok('Business::EDI');
    use_ok('Business::EDI::CodeList');
    $verbose = @ARGV ? shift : 0;
    $Business::EDI::CodeList::verbose = $verbose;
}

my %data = (
#   num  => name
    1159 => "SequenceIdentifierSourceCode",
    1225 => "MessageFunctionCode",
    1227 => "CalculationSequenceCode",
);

my %values = (
    1159 => 1,
    1225 => 28, # Accepted, with amendment in heading section
    1227 => 5,  # Fifth step of calculation
);

$Data::Dumper::Indent = 1;

$verbose and print "data: ", Dumper(\%data);

foreach (sort keys %data) {
    note "#" x 30;
    ok($var1 = Business::EDI::CodeList->new_codelist($_),
              "Business::EDI::CodeList->new_codelist($_)"       );
    ok($var2 = Business::EDI::CodeList->new_codelist($data{$_}),
              "Business::EDI::CodeList->new_codelist($data{$_})");
    is_deeply($var1, $var2, "new_codelist($_) === new_codelist($data{$_})");
    ok($var1 = Business::EDI::CodeList->new_codelist($_, $values{$_}),
              "Business::EDI::CodeList->new_codelist($_, $values{$_})");
    ok($var3 = Business::EDI::CodeList->new_codelist($_, 'Nonsense'),
              "Business::EDI::CodeList->new_codelist($_, 'Nonsense')  -- bad value");
    ok(not($var3->desc),  "No description for Nonsense value");
    ok(not($var3->label), "No label for Nonsense value");
    is($var3->value, 'Nonsense', "Nonsense value preserved");
    ok($var2 = Business::EDI::CodeList->new_codelist($data{$_}, $values{$_}),
              "Business::EDI::CodeList->new_codelist($data{$_}, $values{$_})");
    is_deeply($var1, $var2, "new_codelist($_, $values{$_}) === new_codelist($data{$_}, $values{$_})");
}

note("done");

