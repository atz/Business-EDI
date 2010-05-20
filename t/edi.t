#!/usr/bin/perl
#

use strict; use warnings;

use Data::Dumper;
use Test::More tests => 32;

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

my $debug = @ARGV ? shift : 0;

$Business::EDI::debug = 
$Business::EDI::Spec::debug =
$Data::Dumper::Indent = $debug;

my ($ob1, $edi);
ok($edi = Business::EDI->new(),                  "Business::EDI->new");
ok($edi = Business::EDI->new(version => 'd08a'), "Business::EDI->new(version => 'd08a')");
my @methods = ('new', 'spec', 'codelist', 'segment');
foreach (@methods) {
    can_ok($edi, $_);   # must be real methods, not AUTOLOADed
}
is($edi->spec->version, 'd08a', 'edi->spec->version');
is($edi->spec->interactive,  0, 'edi->spec->interactive');
ok($edi->spec('d07a'),          'edi->spec("d07a")');
is($edi->spec->version, 'd07a', 'edi->spec->version');
# ok(! $edi->spec(spec => 'd08a', 'bad'), 'edi->spec( ODD number of args)');


ok($ob1 = Business::EDI->codelist('ResponseTypeCode', $data->{4343}),
    sprintf("Business::EDI->codelist('ResponseTypeCode', \$X): 4343 Response Type Code '%s' recognized", ($data->{4343} || ''))
);
is_deeply($ob1, Business::EDI->codelist(4343, $data->{4343}), "ResponseTypeCode and 4343 create identical objects");

my $pre = "Identical constructors: Business::EDI->codelist and";
is_deeply($ob1, Business::EDI::CodeList->new_codelist(4343,    $data->{4343}), "$pre Business::EDI::CodeList->new_codelist");
is_deeply($ob1, Business::EDI::CodeList::ResponseTypeCode->new($data->{4343}), "$pre Business::EDI::CodeList::ResponseTypeCode->new");

my ($spec1, $spec2);
foreach my $type (qw/message segment composite element/) {
    ok(  $edi->spec->get_spec_handle($type), "edi->get_spec_handle('$type')");
    ok($spec1 = $edi->spec->get_spec($type), "edi->get_spec('$type')");
    ok($spec2 = $edi->spec->get_spec($type), "edi->get_spec('$type')");   # 
    is_deeply($spec1, $spec2, "cached '$type' spec matches first read");  # 
    # print "$type: ", Dumper($spec1);
}

$debug and print Dumper($spec1->{9619});
