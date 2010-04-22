#!/usr/bin/perl
#

use strict; use warnings;

use Test::More tests => 32;

BEGIN {
    use_ok('Data::Dumper');
    use_ok('Business::EDI');
    use_ok('Business::EDI::Segment::BGM');
}

my $data = {
    '1004' => '582830',
    '4343' => 'AC',
    '1225' => '29',
    'C002' => {
        '1001' => '231'
    }
};

$Data::Dumper::Indent = 1;

use vars qw/%code_hash $bgm/;

print "data: ", Dumper($data);

ok($bgm = Business::EDI::Segment::BGM->new($data), 'Business::EDI::Segment::BGM->new');
ok($bgm->seg4343, "Autoload seg4343 accessor");
is($bgm->seg4343->value, $data->{4343}, "seg4343 value");

print "BGM: ", Dumper($bgm);

my ($msgtype);
ok($msgtype  = Business::EDI->codelist('ResponseTypeCode', $data->{4343}),
    sprintf("Business::EDI->codelist('ResponseTypeCode', \$X): 4343 Response Type Code '%s' recognized", ($data->{4343} || ''))
);
foreach my $key (keys %$data) {
    my ($codelist);
    ok($codelist = $bgm->seg4343->codelist, "Business::EDI::Segment::BGM->new(...)->seg4343->codelist");
    is($msgtype->code,  $bgm->seg4343->code , "Different constructor paths, same code");
    is($msgtype->label, $bgm->seg4343->label, "Different constructor paths, same label");
    is($msgtype->value, $bgm->seg4343->value, "Different constructor paths, same value");
    my $seg4343 = $bgm->seg4343;
    print 'ResponseTypeCode dump: ', Dumper($msgtype);
    print 'bgm->seg4343     dump: ', Dumper($seg4343);
    note(sprintf "Business::EDI->codelist('ResponseTypeCode', \$X): 4343 response type: %s - %s (%s)", $msgtype->code, $msgtype->label, $msgtype->value);
    note(sprintf "Business::EDI::Segment::BGM->new(...)->seg4343\ : 4343 response type: %s - %s (%s)", $seg4343->code, $seg4343->label, $seg4343->value);
    my $fcn = $bgm->seg1225;
    next unless ok( $fcn, 
        sprintf "EDI 1225 Message Function Code '%s' is recognized", ($data->{1225} || ''));
}

# ok($slurp = join('', <DATA>),     "Slurped data from DATA handle");

# note("ref(\$obj): " . ref($perl));
# note("    \$obj : " .     $perl );

note("done");

