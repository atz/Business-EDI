#!/usr/bin/perl
#

use strict; use warnings;

use Test::More tests => 6;

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

my ($ob1);
ok($ob1 = Business::EDI->codelist('ResponseTypeCode', $data->{4343}),
    sprintf("Business::EDI->codelist('ResponseTypeCode', \$X): 4343 Response Type Code '%s' recognized", ($data->{4343} || ''))
);
is_deeply($ob1, Business::EDI->codelist(4343, $data->{4343}), "ResponseTypeCode and 4343 create identical objects");

my $pre = "Identical constructors: Business::EDI->codelist and";
is_deeply($ob1, Business::EDI::CodeList->new_codelist(4343,    $data->{4343}), "$pre Business::EDI::CodeList->new_codelist");
is_deeply($ob1, Business::EDI::CodeList::ResponseTypeCode->new($data->{4343}), "$pre Business::EDI::CodeList::ResponseTypeCode->new");

