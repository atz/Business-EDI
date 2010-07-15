#!/usr/bin/perl
#

use strict; use warnings;

use Test::More tests => 21;

BEGIN {
    use_ok('Data::Dumper');
    use_ok('UNIVERSAL::require');

    use_ok('Business::EDI');
    use_ok('Business::EDI::Spec');
    use_ok('Business::EDI::Test', qw/ordrsp_data/);
}

use vars qw/$perl/;

my $debug = $Business::EDI::debug = $Business::EDI::Spec::debug = @ARGV ? shift : 0;

my $edi = Business::EDI->new('d08a') or die "Business::EDI->new('d08a') failed";

ok($perl = ordrsp_data, "DATA handle read and decode" );
$perl or die "DATA handle not decoded successfully";

$Data::Dumper::Indent = 1;

is(scalar(@{$perl->{body}}), 3, "EDI interchange body has 3 messages");

my $msgcode = 'ORDRSP';
my $spec = $edi->spec->get_spec('message');
ok($spec,"\$edi->spec->get_spec('message')");
ok($spec->{$msgcode}, "\$edi->spec->get_spec('message')->{$msgcode}");
#print "Dump of ORDRSP spec: ", Dumper($spec->{ORDRSP});

my $sg_spec = $edi->spec->get_spec('segment_group');
ok($sg_spec,"\$edi->spec->get_spec('segment_group')");
ok($sg_spec->{$msgcode}, "\$edi->spec->get_spec('segment_group')->{$msgcode}");

is_deeply($sg_spec->{$msgcode}->{SG26}, $spec->{"$msgcode/SG26"}, "SG_SPECS->{$msgcode}->{SG26} === MSG_SPECS->{'$msgcode/SG26'}");

my $i=0;
foreach my $part (@{$perl->{body}}) {
    $i++;
    next unless ok((ref $part and scalar keys %$part), "EDI interchange message $i has structure.");
    foreach my $key (keys %$part) {
        next unless ok($key eq 'ORDRSP', "EDI interchange message $i type == ORDRSP");
        my $ordrsp;
        ok($ordrsp = $edi->detect_version($part->{$key}), "EDI $key object via \$edi->detect_version(...)");
    }
}

note("done");

__END__

ORDRSP SG26 (different versions)
Notice that the content changes completely at d94b and d06a, because the SG26 designation is just the relative position of the
segment group, not a name for it.  This makes parsing rather difficult.


1911   PRI;M;1;API;C;1;RNG;C;1;DTM;C;5
1921   PAT;M;1;DTM;C;5;PCD;C;1;MOA;C;1
d93a   PAT;M;1;DTM;C;5;PCD;C;1;MOA;C;1
s93a   PAT;M;1;DTM;C;5;PCD;C;1;MOA;C;1
d94a   PAT;M;1;DTM;C;5;PCD;C;1;MOA;C;1
d94b   PAT;M;1;DTM;C;5;PCD;C;1;MOA;C;1
d95a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;5;QTY;C;10;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;5;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;5;PAI;C;1;FTX;C;5;SG27;C;10;SG28;C;1;SG29;C;25;SG30;C;10;SG31;C;10;SG34;C;9999;SG35;C;5;SG36;C;10;SG40;C;15;SG46;C;10;SG48;C;5;SG49;C;10;SG50;C;100;SG52;C;100;SG53;C;10
d95b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;5;QTY;C;10;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;5;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;5;PAI;C;1;FTX;C;5;SG27;C;10;SG28;C;1;SG29;C;25;SG30;C;10;SG31;C;10;SG34;C;9999;SG35;C;5;SG36;C;10;SG40;C;15;SG46;C;10;SG48;C;5;SG49;C;10;SG50;C;100;SG52;C;100;SG53;C;10
d96a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;5;QTY;C;10;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;5;PAI;C;1;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;999;SG32;C;10;SG35;C;9999;SG36;C;10;SG37;C;99;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;100;SG54;C;10
d96b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;10;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;5;PAI;C;1;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;999;SG32;C;10;SG35;C;9999;SG36;C;10;SG37;C;99;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;100;SG54;C;10
d97a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;10;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;5;PAI;C;1;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;999;SG32;C;10;SG35;C;9999;SG36;C;10;SG37;C;99;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;100;SG54;C;10
d97b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;10;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d98a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d98b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIS;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d99a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIS;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d99b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIS;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d00a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIS;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d00b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIS;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d01a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIS;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d01b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIS;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d01c   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIS;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d02a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GIS;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d02b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GEI;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d03a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GEI;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d03b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GEI;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d04a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GEI;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d04b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GEI;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d05a   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GEI;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d05b   LIN;M;1;PIA;C;25;IMD;C;99;MEA;C;99;QTY;C;99;PCD;C;5;ALI;C;5;DTM;C;35;MOA;C;10;GEI;C;99;GIN;C;1000;GIR;C;1000;QVR;C;1;DOC;C;99;PAI;C;1;MTD;C;99;FTX;C;99;SG27;C;999;SG28;C;10;SG29;C;1;SG30;C;25;SG31;C;9999;SG32;C;99;SG35;C;9999;SG36;C;10;SG37;C;999;SG41;C;99;SG47;C;10;SG49;C;5;SG50;C;10;SG51;C;100;SG53;C;999;SG54;C;10
d06a   EFI;M;1;CED;C;99;COM;C;9;RFF;C;9;DTM;C;9;QTY;C;9
d06b   EFI;M;1;CED;C;99;COM;C;9;RFF;C;9;DTM;C;9;QTY;C;9
d07a   EFI;M;1;CED;C;99;COM;C;9;RFF;C;9;DTM;C;9;QTY;C;9
d07b   EFI;M;1;CED;C;99;COM;C;9;RFF;C;9;DTM;C;9;QTY;C;9
d08a   EFI;M;1;CED;C;99;COM;C;9;RFF;C;9;DTM;C;9;QTY;C;9

