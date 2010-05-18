#!/usr/bin/perl
#

use strict; use warnings;

use Test::More tests => 19;

BEGIN {
    use_ok('Business::EDI');
    use_ok('Business::EDI::CodeList');
}

my $data = {
    '1004' => '582830',
    '4343' => 'AC',
    '1225' => '29',
    'C002' => {
        '1001' => '231'
    }
};

$Business::EDI::debug = 1;
my ($ob1, $edi);
ok($edi = Business::EDI->new(),               "Business::EDI->new");
ok($edi = Business::EDI->new(spec => 'd08a'), "Business::EDI->new(spec => 'd08a')");
my @methods = ('new', 'spec', 'codelist', 'segment', 'get_spec_handle');
foreach (@methods) {
    can_ok($edi, $_);   # must be real methods, not AUTOLOADed
}
is($edi->spec, 'd08a', 'edi->spec()');
is($edi->interactive, 0, 'edi->interactive');
ok($edi->spec('d07a'), 'edi->spec("d07a")');
is($edi->spec, 'd07a', 'edi->spec()');
# ok(! $edi->spec(spec => 'd08a', 'bad'), 'edi->spec( ODD number of args)');


ok($ob1 = Business::EDI->codelist('ResponseTypeCode', $data->{4343}),
    sprintf("Business::EDI->codelist('ResponseTypeCode', \$X): 4343 Response Type Code '%s' recognized", ($data->{4343} || ''))
);
is_deeply($ob1, Business::EDI->codelist(4343, $data->{4343}), "ResponseTypeCode and 4343 create identical objects");

my $pre = "Identical constructors: Business::EDI->codelist and";
is_deeply($ob1, Business::EDI::CodeList->new_codelist(4343,    $data->{4343}), "$pre Business::EDI::CodeList->new_codelist");
is_deeply($ob1, Business::EDI::CodeList::ResponseTypeCode->new($data->{4343}), "$pre Business::EDI::CodeList::ResponseTypeCode->new");

my %factors = (
    message => 3,
);
my $spec;
foreach my $type (qw/message segment composite codelist element/) {

    ok($spec = $edi->get_spec_handle($type), "edi->get_spec_handle('$type')");

# 010;C780;M;1;
    foreach (<$spec>) {
        chomp;
        my ($code, $name, @rest) = split ';', $_;
        note($_);
        $code = (split ':', $code)[0];
        is(scalar(@rest) % 4, 0, "$type/$code has right number of components, a factor of 4 (" . sprintf("%2d", scalar(@rest)) . ")");
    }
}
