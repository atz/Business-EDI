#!/usr/bin/perl
#

use strict; use warnings;

use Test::More tests => 275;

BEGIN {
    use_ok('Data::Dumper');
    use_ok('UNIVERSAL::require');

    use_ok('Business::EDI');
    use_ok('Business::EDI::Spec');
    use_ok('Business::EDI::Test', qw/JSONObject2Perl ordrsp_data/);
}

sub sg_sort {
    return Business::EDI::Spec->sg_sort(@_);
}
sub spec_version_sort {
    return Business::EDI::Spec->spec_version_sort(@_);
}

use vars qw/%code_hash $slurp $perl/;

my $debug = $Business::EDI::debug = $Business::EDI::Spec::debug = @ARGV ? shift : 0;

my $edi = Business::EDI->new('d08a') or die "Business::EDI->new('d08a') failed";

ok($perl = ordrsp_data, "DATA handle read and decode" );

$perl or die "DATA handle not decoded successfully";
# note("ref(\$obj): " . ref($perl));
# note("    \$obj : " .     $perl );

$Data::Dumper::Indent = 1;

ok($perl->{body},      "EDI interchange body");
ok($perl->{body}->[0], "EDI interchange body is a populated arrayref!");
is(scalar(@{$perl->{body}}), 3, "EDI interchange body has 3 messages");

is($edi->spec->syntax, 40100, "\$edi->spec->syntax");

my $spec;
   $spec = $edi->spec->get_spec('segment');
ok($spec,"\$edi->spec->get_spec('segment')");

my @failed;

foreach (qw/
ADR  AGR  AJT  ALC  ALI  APP  APR  ARD  ARR  ASI  ATT  AUT  BAS  BGM  BII
BUS  CAV  CCD  CCI  CDI  CDS  CDV  CED  CIN  CLA  CLI  CMP  CNI  CNT  COD
COM  COT  CPI  CPS  CPT  CST  CTA  CUX  DAM  DFN  DGS  DII  DIM  DLI  DLM
DMS  DOC  DRD  DSG  DSI  DTM  EDT  EFI  ELM  ELU  ELV  EMP  EQA  EQD  EQN
ERC  ERP  EVE  FCA  FII  FNS  FNT  FOR  FSQ  FTX  GDS  GEI  GID  GIN  GIR
GOR  GPO  GRU  HAN  HYN  ICD  IDE  IFD  IHC  IMD  IND  INP  INV  IRQ  LAN
LIN  LOC  MEA  MEM  MKS  MOA  MSG  MTD  NAD  NAT  PAC  PAI  PAS  PCC  PCD
PCI  PDI  PER  PGI  PIA  PNA  POC  PRC  PRI  PRV  PSD  PTY  PYT  QRS  QTY
QUA  QVR  RCS  REL  RFF  RJL  RNG  ROD  RSL  RTE  SAL  SCC  SCD  SEG  SEL
SEQ  SFI  SGP  SGU  SPR  SPS  STA  STC  STG  STS  TAX  TCC  TDT  TEM  TMD
TMP  TOD  TPL  TRU  TSR  VLI
/) {
    ok($spec->{$_}, "\$edi->spec->get_spec('segment')->{$_}") or push @failed, $_;
}

my $i=0;
if ($debug) {
    print "ALL segment keys:\n";
    foreach (sort keys %$spec) {
        print $_, (++$i % 15 == 0 ? "\n" : "  ");
    }
    print "\n";
}

if (@failed) {
    $i=0;
    diag("FAILED segment codes:");
    foreach (@failed) {
        print $_, (++$i % 15 == 0 ? "\n" : "  ");
    }
    diag();
}

my $msgcode = 'ORDRSP';
   $spec = $edi->spec->get_spec('message');
ok($spec,"\$edi->spec->get_spec('message')");
ok($spec->{$msgcode}, "\$edi->spec->get_spec('message')->{$msgcode}");
#print "Dump of ORDRSP spec: ", Dumper($spec->{ORDRSP});

my $sg_spec = $edi->spec->get_spec('segment_group');
ok($sg_spec,"\$edi->spec->get_spec('segment_group')");
ok($sg_spec->{$msgcode}, "\$edi->spec->get_spec('segment_group')->{$msgcode}");

is_deeply($sg_spec->{$msgcode}->{SG26}, $spec->{"$msgcode/SG26"}, "SG_SPECS->{$msgcode}->{SG26} === MSG_SPECS->{'$msgcode/SG26'}");

sub sg_expander {
    my ($countsref, $mapref, $msgcode, $parts, $depth) = @_;
    $depth ||= 1;
    $debug and note("\$edi->spec->get_spec('message')->xpath('$msgcode')");
    foreach my $part (@$parts) {
        my $code = $part->{code};
        $countsref->{$depth}->{$code}++;
        $mapref->{$depth}->{$code} = "$msgcode/$code";
        $debug and note("\$edi->spec->get_spec('message')->xpath('$msgcode/$code') " . $countsref->{$depth}->{$code});
    }
    my $i = scalar @$parts;
    my $spec_key = $msgcode;
    $spec_key =~ s#/.+##; # and print "SPEC_KEY stripped: $spec_key\n";
    foreach (grep {/^SG\d+$/} map {$_->{code}} @$parts) {
        $debug and note("Depth=" . ($depth+1) . " check $msgcode/$_ ($spec_key)");
        $i += sg_expander($countsref, $mapref, "$msgcode/$_", $spec->{"$spec_key/$_"}->{parts}, $depth+1);
        # recursion for depth!
    }
    return $i;
}

my %scratch  = ();
my %deep_map = ();
my %counts   = ();

my @keys = sort {&sg_sort($a,$b)} map {$_->{code}} @{$spec->{$msgcode}->{parts}};
foreach my $key (@keys) {
    $key =~ /SG\d+$/ or next;
    $sg_spec->{$msgcode}->{$key} and
        is_deeply($sg_spec->{$msgcode}->{$key},     $spec->{"$msgcode/$key"},
                "\$sg_spec->{$msgcode}->{$key} vs. \$spec->{'$msgcode/$key'}");
    my @parts = @{$spec->{"$msgcode/$key"}->{parts}};
    sg_expander(\%counts, \%scratch, "$msgcode/$key", \@parts);
}

my @single_keys = grep {$counts{1}->{$_} == 1} keys %{$counts{1}};
my @mutli_keys  = grep {$counts{1}->{$_}  > 1} keys %{$counts{1}};
is(scalar @single_keys, 56, "Depth 1 Deeploadable keys: 56");
is(scalar @mutli_keys, 10, "Depth 1 NOT Deeploadable keys: 10");

if ($debug) {
    my @depths = sort keys %counts;
    DEPTH: foreach my $d (@depths) {
        my @single = sort {&sg_sort($a,$b)} grep {$counts{$d}->{$_} == 1} keys %{$counts{$d}};
        my @mutli  = sort {&sg_sort($a,$b)} grep {$counts{$d}->{$_}  > 1} keys %{$counts{$d}};

        KEY: foreach my $key (@single) {
            foreach my $other (grep {$_ < $d} @depths) {    # check shallower depths (we go in order, so we haven't seen deeper ones yet)
                if ($counts{$other}->{$key}) {
                    printf "Blocked %-4s %2d hits (already at depth=$other)\n", $key, $counts{$other}->{$key};
                    next KEY;
                }
            }
            $deep_map{$key} and warn "Internal ERROR: $key is already deepmapped??";
            $deep_map{$key} = $scratch{$d}->{$key};
            printf "        %-4s => %-25s (depth=$d)\n", $key, $deep_map{$key};
        }
        foreach my $key (@mutli) {
            printf "MUTLI   %-4s %2d hits   %s\n", $key, $counts{$d}->{$key},
                join(", ",
                    map {sprintf "%2d\@depth=$_", $counts{$_}->{$key}}
                    grep {$_ != $d and $counts{$_}->{$key}}
                    @depths
                );
        }
    }
}

$i=0;
foreach my $part (@{$perl->{body}}) {
    $i++;
    next unless ok((ref $part and scalar keys %$part), "EDI interchange message $i has structure.");
    foreach my $key (keys %$part) {
        next unless ok($key eq 'ORDRSP', "EDI interchange message $i type == ORDRSP");
        my $ordrsp;
        ok($ordrsp = $edi->message($key, $part->{$key}), "EDI $key object via \$edi->message($key, ...)");
    }
}

my $specs = {};
my $sgs = {};
my @versions = qw/
 1901   1902   1911   1921   2932
 d93a   s93a   d94a   d94b   d95a   d95b   d96a   d96b
 d97a   d97b   d98a   d98b   d99a   d99b
 d00a   d00b   d01a   d01b   d01c
 d02a   d02b   d03a   d03b   d04a
 d04b   d05a   d05b   d06a   d06b   d07a   d07b   d08a
/;

my @sorted_vers = sort {spec_version_sort($a,$b)} qw/
 d04b   d05a   d05b   d06a   d06b   d07a   d07b   d08a
 1901   1902   2932   1921   1911
 d00a   d00b   d01c   d01a   d01b
 d95a   d95b   d96a   d96b   s93a   d93a   d94a   d94b
 d97a   d97b   d98a   d98b   d99a   d99b
 d02b   d02a   d03a   d03b   d04a
/;
# We check whether the arrays match later

foreach (@versions) {
    ok($specs->{$_} = Business::EDI->new(version => $_)->spec, "Business::EDI->new(version => '$_')->spec()") or next;
    ok($specs->{$_}->spec_page('message'),                     "Business::EDI->new(version => '$_')->spec->spec_page('message')") or next;;
}


my @msgs = qw/ ORDERS ORDRSP INVOIC /;

note "Analyzing " . scalar(@versions) . " spec versions";

foreach my $v (@versions) {
    my @allkeys = sort keys %{$specs->{$v}->spec_page('message')};
    my @msgtypes = grep {!/\//} @allkeys;
    note "\n$v has " . sprintf("%3d", scalar(@msgtypes)) . " message types (eg: " . join(' ', @msgtypes[0..3]) . " ...)";
    foreach my $msg (@msgs) {
        my @sgkeys = sort {sg_sort($a, $b)} grep {/^$msg\/SG/} @allkeys;
        note "$v $msg has " . sprintf("%3d", scalar(@sgkeys)) . " Segment Groups";
        foreach my $fullkey (@sgkeys) {
            $_ = $fullkey;
            s/^.*\///;
            $sgs->{$v}->{$msg}->{$_} = $specs->{$v}->spec_page('message')->{$fullkey};
            my @parts = @{ $sgs->{$v}->{$msg}->{$_}->{parts} };
            note sprintf("$v %11s has %3d parts: ", $fullkey, scalar(@parts)) . join " ", map {$_->{code}} @parts;
        }
    }
}



my @unsorted = qw# SG47 SG18 ORDRSP/SG26 INVOIC/SG26 INVOIC/SG1 ORDRSP/SG4 SG1 #;
note "sorted: " . join " ", sort{sg_sort($a,$b)} @unsorted;
is_deeply(\@sorted_vers, \@versions, "spec_version_sort");

#print Dumper($specs->{d96a}), "\n";
note("done");

__END__

