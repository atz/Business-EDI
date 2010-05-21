#!/usr/bin/perl
#

use strict; use warnings;

use Test::More tests => 812;

BEGIN {
    use_ok('Data::Dumper');
    use_ok('UNIVERSAL::require');

    use_ok('Business::EDI');
    use_ok('Business::EDI::DataElement');
    use_ok('Business::EDI::Segment::RFF');
    use_ok('Business::EDI::Segment::BGM');
    use_ok('JSON::XS');
}

use vars qw/%code_hash $parser $slurp $json $perl/;

ok($parser = JSON::XS->new, 'JSON::XS->new');
$parser->ascii(1);        # output \u escaped strings for any char with a value over 127
$parser->allow_nonref(1); # allows non-reference values to equate to themselves (see perldoc)

my $debug = $Business::EDI::debug = @ARGV ? shift : 0;

my $edi = Business::EDI->new('d08a') or die "Business::EDI->new('d08a') failed";

sub parse_ordrsp {
    my ($segments) = @_;
    my $type = 'ORDRSP';
    my @lins;
    foreach my $segment (@$segments) {
        my ($tag, $segbody, @extra) = @$segment;
        next unless ok($tag,     "EDI segment tag received (not empty)");
        next unless ok($segbody, "EDI segment '$tag' has body");
        if ($tag eq 'UNH') {
            return unless ok( ($segbody->{S009}->{'0065'} and $segbody->{S009}->{'0065'} eq $type), 
                "EDI $tag/S009/0065 ('" . ($segbody->{S009}->{'0065'} || '') . "') matches message type ($type)");
            ok( ($segbody->{S009}->{'0051'} and $segbody->{S009}->{'0051'} eq 'UN'), 
                "EDI segment $tag/S009/0051 designates 'UN' as controlling agency"
            );
        } elsif ($tag eq 'BGM') {
            my ($bgm, $msgtype, $codelist);
            $debug and print "BGM dump: ", Dumper($segbody);
            ok( $bgm = Business::EDI::Segment::BGM->new($segbody), "Business::EDI::Segment::BGM->new");
            ok( $codelist = $bgm->part4343, "Business::EDI::Segment::BGM->new(...)->seg4343->codelist");
            ok( $msgtype = Business::EDI->codelist('ResponseTypeCode', $segbody->{4343}),
                sprintf("Business::EDI->codelist('ResponseTypeCode', \$X): $tag/4343 Response Type Code '%s' recognized", ($segbody->{4343} || ''))
            );
            is($msgtype->label, $bgm->seg4343->label, "Different constructor paths, same label");
            is($msgtype->value, $bgm->seg4343->value, "Different constructor paths, same value");
            is($msgtype->desc,  $bgm->seg4343->desc,  "Different constructor paths, same description"); 
            my $seg4343 = $bgm->seg4343;
            $debug and print 'ResponseTypeCode dump: ', Dumper($msgtype);
            $debug and print 'bgm->seg4343     dump: ', Dumper($seg4343);
            note(sprintf "Business::EDI->codelist('ResponseTypeCode', \$X): $tag/4343 response type: %s - %s (%s)", $msgtype->value, $msgtype->label, $msgtype->desc);
            note(sprintf "Business::EDI::Segment::BGM->new(...)->seg4343\ : $tag/4343 response type: %s - %s (%s)", $seg4343->value, $seg4343->label, $seg4343->desc);
            my $fcn = $bgm->seg1225;
            return unless ok( $fcn, 
                sprintf "EDI $tag/1225 Message Function Code '%s' is recognized", ($segbody->{1225} || ''));
        } elsif ($tag eq 'LIN') {
            my @chunks = @{$segbody->{SG26}};
            my $count = scalar(@chunks);
            foreach (@chunks) {
                my $label = $_->[0];
                my $body  = $_->[1];
                $label eq 'RFF' or next;
                my $obj;
                ok($obj = $edi->segment('RFF', $body),   "EDI $tag/$label converts to an object");
                is_deeply(Business::EDI::Segment::RFF->new($body), $obj, "EDI $tag/$label matching constructors");
                ok($obj->partC506->seg1153,              "EDI $tag/$label/C506/seg1153 exists");
                is($obj->partC506->seg1153->value, 'LI', "EDI $tag/$label/C506/seg1153 has value ('LI')") or print Dumper($obj->partC506->seg1153);
                ok($obj->part1153,                       "EDI $tag/$label/part1153 exists (collapsable Composite)") or print "OBJ: " . Dumper($obj);
                is($obj->part1153->value,          'LI', "EDI $tag/$label/part1153 has value ('LI') (collapsable Composite)") or print Dumper($obj->seg1153);
            }
            push @lins, \@chunks;
        } else {
            # note("EDI: ignoring segment '$tag'");
        }
    }
    return @lins;
}

sub JSONObject2Perl {
    my $obj = shift;
    if ( ref $obj eq 'HASH' ) {
        if ( defined $obj->{'__c'} ) {
            die "We somehow got a special (Evergreen) object in our data";
        }
        # is a hash w/o class marker; simply revivify innards
        for my $k (keys %$obj) {
            $obj->{$k} = JSONObject2Perl($obj->{$k}) unless ref $obj->{$k} eq 'JSON::XS::Boolean';
        }
    } elsif ( ref $obj eq 'ARRAY' ) {
        for my $i (0..scalar(@$obj) - 1) {
            $obj->[$i] = JSONObject2Perl($obj->[$i]) unless ref $obj->[$i] eq 'JSON::XS::Boolean';
        }
    } 
    # ELSE: return vivified non-class hashes, all arrays, and anything that isn't a hash or array ref
    return $obj;
}

ok($slurp = join('', <DATA>),     "Slurped data from DATA handle");
my $foo = ($parser->decode($slurp));
ok($foo, "decode slurp");
ok($perl = JSONObject2Perl($foo), "DATA handle read and decode" );

$perl or die "DATA handle not decode successfully";
# note("ref(\$obj): " . ref($perl));
# note("    \$obj : " .     $perl );

$Data::Dumper::Indent = 1;

=pod
    ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["LACY, AL THINGS NOT SEEN"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ...
            ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/1"
            }
        }], ... ]}]

=cut

ok($perl->{body},      "EDI interchange body");
ok($perl->{body}->[0], "EDI interchange body is a populated arrayref!");
is(scalar(@{$perl->{body}}), 3, "EDI interchange body has 3 messages");

my @li = ();
my $i = 0;
foreach my $part (@{$perl->{body}}) {
    $i++;
    next unless ok((ref $part and scalar keys %$part), "EDI interchange message $i has structure.");
    foreach my $key (keys %$part) {
        next unless ok($key eq 'ORDRSP', "EDI interchange message $i type == ORDRSP");
        my @li_chunk = parse_ordrsp($part->{$key});
        note("EDI $key parsing returned " . scalar(@li_chunk) . " line items");
        push @li, @li_chunk;
    }
}


my @rffs = ();
my @qtys = ();
foreach (@li) {
   my $count = scalar(@$_);
   is($count, 7, "->{SG26} has 7 pieces: ");
   note("\t\t" . join ' ', map {$_->[0]} @{$_});
   for (my $i = 0; $i < $count; $i++) {
        my $label = $_->[$i]->[0];
        my $body  = $_->[$i]->[1];
        $label eq 'QTY' and push @qtys, $body;
        $label eq 'RFF' and push @rffs, $body;
    }
}

is(scalar(@li  ),  58, " 58 LINs found");
is(scalar(@qtys), 174, "174 QTYs found");
is(scalar(@rffs),  58, " 58 RFFs found (inside LINs)");

# We want: RFF > C506 > 1154 where 1153 = LI
foreach my $rff (@rffs) {
    my $obj = Business::EDI::Segment::RFF->new($rff);
    ok($obj, 'Business::EDI::Segment::RFF->new()');
    # print Dumper ($obj);
    foreach my $subrff (keys %$rff) {
        $subrff eq 'C506' or next;
        my $i = 0;
        foreach (sort keys %{$rff->{$subrff}}) {
            my $x = Business::EDI::DataElement->new($_, $rff->{$subrff}->{$_});
            # print "$_ ", $x->label, " ", $x->value, " ";
            # $i++ == 0 and print "==> ";
            ok($x, "Business::EDI::DataElement->new($_, ...)");
        }
    }
}
note("done");

__DATA__
{
"trailer": ["UNZ", {
    "0020": "2045",
    "0036": 1
}],
"body": [{
    "ORDRSP": [["UNH", {
        "S009": {
            "0052": "D",
            "0054": "96A",
            "0065": "ORDRSP",
            "0051": "UN"
        },
        "0062": "723"
    }], ["BGM", {
        "4343": "AC",
        "1225": "29",
        "C002": {
            "1001": "231"
        },
        "1004": "582822"
    }], ["DTM", {
        "C507": {
            "2379": "102",
            "2380": "20070618",
            "2005": "137"
        }
    }], ["RFF", {
        "C506": {
            "1153": "ON",
            "1154": "E07158FIC"
        }
    }], ["NAD", {
        "C082": {
            "3039": "8888888",
            "3055": "31B"
        },
        "3035": "BY"
    }], ["NAD", {
        "C082": {
            "3039": "1556150",
            "3055": "31B"
        },
        "3035": "SU"
    }], ["NAD", {
        "C082": {
            "3039": "8888888",
            "3055": "91"
        },
        "3035": "BY"
    }], ["CUX", {
        "C504": [{
            "6345": "USD",
            "6347": "2",
            "6343": "9"
        }]
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["LACY, AL THINGS NOT SEEN"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 10.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/1"
            }
        }]],
        "C212": {
            "7140": "9781576734131",
            "7143": "EN"
        },
        "1082": 1,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["LACY, AL FINAL JUSTICE"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 1,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 1,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/2"
            }
        }]],
        "C212": {
            "7140": "9781590529966",
            "7143": "EN"
        },
        "1082": 2,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["MALAMUD, B NATURAL"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/3"
            }
        }]],
        "C212": {
            "7140": "9780374502003",
            "7143": "EN"
        },
        "1082": 3,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["SCOTT, PAU RAJ QUARTET THE JEWEL IN"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 32.5
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/4"
            }
        }]],
        "C212": {
            "7140": "9780307263964",
            "7143": "EN"
        },
        "1082": 4,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["JAMES, P.  SHROUD FOR A NIGHTINGALE"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/6"
            }
        }]],
        "C212": {
            "7140": "9780743219600",
            "7143": "EN"
        },
        "1082": 5,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["LAHAYE, TI TRIBULATION FORCE THE CO"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/7"
            }
        }]],
        "C212": {
            "7140": "9780842329217",
            "7143": "EN"
        },
        "1082": 6,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["ZANE AFTERBURN A NOVEL"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 15
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/8"
            }
        }]],
        "C212": {
            "7140": "9780743470988",
            "7143": "EN"
        },
        "1082": 7,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["CABOT, MEG BOY NEXT DOOR"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 13.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/9"
            }
        }]],
        "C212": {
            "7140": "9780060096199",
            "7143": "EN"
        },
        "1082": 8,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["VONNEGUT,  BREAKFAST OF CHAMPIONS"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/10"
            }
        }]],
        "C212": {
            "7140": "9780385334204",
            "7143": "EN"
        },
        "1082": 9,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["DOSTOYEVSK BROTHERS KARAMAZOV"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 9.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/11"
            }
        }]],
        "C212": {
            "7140": "9781593083526",
            "7143": "EN"
        },
        "1082": 10,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["KINGSBURY, FORGIVEN"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 13.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/12"
            }
        }]],
        "C212": {
            "7140": "9780842387446",
            "7143": "EN"
        },
        "1082": 11,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["BERLINSKI, FIELDWORK"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 24
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/13"
            }
        }]],
        "C212": {
            "7140": "9780374299163",
            "7143": "EN"
        },
        "1082": 12,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["GREGORY, P MERIDON A NOVEL"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 16
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/14"
            }
        }]],
        "C212": {
            "7140": "9780743249317",
            "7143": "EN"
        },
        "1082": 13,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["MCCALL SMI MORALITY FOR BEAUTIFUL G"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 12.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/15"
            }
        }]],
        "C212": {
            "7140": "9781400031368",
            "7143": "EN"
        },
        "1082": 14,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["CLEAGE, PE WHAT LOOKS LIKE CRAZY ON"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 13.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/16"
            }
        }]],
        "C212": {
            "7140": "9780380794874",
            "7143": "EN"
        },
        "1082": 15,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["GREGORY, P WIDEACRE"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 16
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/17"
            }
        }]],
        "C212": {
            "7140": "9780743249294",
            "7143": "EN"
        },
        "1082": 16,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["FERBER, ED SO BIG"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "07",
                "3055": "28",
                "1131": "7B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 13
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/18"
            }
        }]],
        "C212": {
            "7140": "9780060956691",
            "7143": "EN"
        },
        "1082": 17,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["GREGORY, P OTHER BOLEYN GIRL"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 16
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4639/19"
            }
        }]],
        "C212": {
            "7140": "9780743227445",
            "7143": "EN"
        },
        "1082": 18,
        "1229": "5"
    }], ["UNS", {
        "0081": "S"
    }], ["CNT", {
        "C270": {
            "6069": "2",
            "6066": 18
        }
    }], ["UNT", {
        "0074": 155,
        "0062": "723"
    }]]
},
{
    "ORDRSP": [["UNH", {
        "S009": {
            "0052": "D",
            "0054": "96A",
            "0065": "ORDRSP",
            "0051": "UN"
        },
        "0062": "724"
    }], ["BGM", {
        "4343": "AC",
        "1225": "29",
        "C002": {
            "1001": "231"
        },
        "1004": "582828"
    }], ["DTM", {
        "C507": {
            "2379": "102",
            "2380": "20070618",
            "2005": "137"
        }
    }], ["RFF", {
        "C506": {
            "1153": "ON",
            "1154": "E07159ANF"
        }
    }], ["NAD", {
        "C082": {
            "3039": "8888888",
            "3055": "31B"
        },
        "3035": "BY"
    }], ["NAD", {
        "C082": {
            "3039": "1556150",
            "3055": "31B"
        },
        "3035": "SU"
    }], ["NAD", {
        "C082": {
            "3039": "8888888",
            "3055": "91"
        },
        "3035": "BY"
    }], ["CUX", {
        "C504": [{
            "6345": "USD",
            "6347": "2",
            "6343": "9"
        }]
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["HOLM, BILL WINDOWS OF BRIMNES"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 22
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/1"
            }
        }]],
        "C212": {
            "7140": "9781571313027",
            "7143": "EN"
        },
        "1082": 1,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["REPA, BARB YOUR RIGHTS IN THE WORKP"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 29.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/2"
            }
        }]],
        "C212": {
            "7140": "9781413306439",
            "7143": "EN"
        },
        "1082": 2,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["GUERIN, LI ESSENTIAL GUIDE TO WORKP"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 39.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/3"
            }
        }]],
        "C212": {
            "7140": "9781413306910",
            "7143": "EN"
        },
        "1082": 3,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["CLIFFORD,  ESTATE PLANNING BASICS"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 21.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/4"
            }
        }]],
        "C212": {
            "7140": "9781413307023",
            "7143": "EN"
        },
        "1082": 4,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["FRIEDMAN,  BABY CARE BOOK"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 29.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/5"
            }
        }]],
        "C212": {
            "7140": "9780778801603",
            "7143": "EN"
        },
        "1082": 5,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["KING, RUSS ATLAS OF HUMAN MIGRATION"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 40
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/6"
            }
        }]],
        "C212": {
            "7140": "9781554072873",
            "7143": "EN"
        },
        "1082": 6,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["ASH, RUSSE FIREFLYS WORLD OF FACTS"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 29.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/7"
            }
        }]],
        "C212": {
            "7140": "9781554073139",
            "7143": "EN"
        },
        "1082": 7,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["WARNER, RA 101 LAW FORMS FOR PERSON"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 29.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/8"
            }
        }]],
        "C212": {
            "7140": "9781413307122",
            "7143": "EN"
        },
        "1082": 8,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["BRAY, ILON NOLOS ESSENTIAL GUIDE TO"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 10,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 10,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 24.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/9"
            }
        }]],
        "C212": {
            "7140": "9781413306286",
            "7143": "EN"
        },
        "1082": 9,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["WESTWOOD,  HOW TO WRITE A MARKETING"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 1,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "99",
                "3055": "28",
                "1131": "7B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 17.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/10"
            }
        }]],
        "C212": {
            "7140": "9780749445546",
            "7143": "EN"
        },
        "1082": 10,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["ROANE, SUS HOW TO WORK A ROOM YOUR "]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/11"
            }
        }]],
        "C212": {
            "7140": "9780061238673",
            "7143": "EN"
        },
        "1082": 11,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["GERMAIN, D REACHING PAST THE WIRE A"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 24.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/12"
            }
        }]],
        "C212": {
            "7140": "9780873516068",
            "7143": "EN"
        },
        "1082": 12,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["KLING, KEV DOG SAYS HOW"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 22.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/13"
            }
        }]],
        "C212": {
            "7140": "9780873515993",
            "7143": "EN"
        },
        "1082": 13,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["SHORT, SUS BUNDT CAKE BLISS DELICIO"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 16.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/14"
            }
        }]],
        "C212": {
            "7140": "9780873515856",
            "7143": "EN"
        },
        "1082": 14,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["BRADY, TIM GOPHER GOLD LEGENDARY FI"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 24.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/15"
            }
        }]],
        "C212": {
            "7140": "9780873516013",
            "7143": "EN"
        },
        "1082": 15,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["ROBERTS, K MINNESOTA 150 THE PEOPLE"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 19.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/16"
            }
        }]],
        "C212": {
            "7140": "9780873515948",
            "7143": "EN"
        },
        "1082": 16,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["MAK, GEERT IN EUROPE A JOURNEY THRO"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 35
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/17"
            }
        }]],
        "C212": {
            "7140": "9780375424953",
            "7143": "EN"
        },
        "1082": 17,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["DONAHUE, P PARENTING WITHOUT FEAR O"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/18"
            }
        }]],
        "C212": {
            "7140": "9780312358914",
            "7143": "EN"
        },
        "1082": 18,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["MURRAY, LI BABYCENTERS ESSENTIAL GU"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 15.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/19"
            }
        }]],
        "C212": {
            "7140": "9781594864117",
            "7143": "EN"
        },
        "1082": 19,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["LAPINE, MI SNEAKY CHEF SIMPLE STRAT"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 17.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4640/20"
            }
        }]],
        "C212": {
            "7140": "9780762430758",
            "7143": "EN"
        },
        "1082": 20,
        "1229": "5"
    }], ["UNS", {
        "0081": "S"
    }], ["CNT", {
        "C270": {
            "6069": "2",
            "6066": 20
        }
    }], ["UNT", {
        "0074": 171,
        "0062": "724"
    }]]
},
{
    "ORDRSP": [["UNH", {
        "S009": {
            "0052": "D",
            "0054": "96A",
            "0065": "ORDRSP",
            "0051": "UN"
        },
        "0062": "725"
    }], ["BGM", {
        "4343": "AC",
        "1225": "29",
        "C002": {
            "1001": "231"
        },
        "1004": "582830"
    }], ["DTM", {
        "C507": {
            "2379": "102",
            "2380": "20070618",
            "2005": "137"
        }
    }], ["RFF", {
        "C506": {
            "1153": "ON",
            "1154": "E07160FIC"
        }
    }], ["NAD", {
        "C082": {
            "3039": "8888888",
            "3055": "31B"
        },
        "3035": "BY"
    }], ["NAD", {
        "C082": {
            "3039": "1556150",
            "3055": "31B"
        },
        "3035": "SU"
    }], ["NAD", {
        "C082": {
            "3039": "8888888",
            "3055": "91"
        },
        "3035": "BY"
    }], ["CUX", {
        "C504": [{
            "6345": "USD",
            "6347": "2",
            "6343": "9"
        }]
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["SHAW, REBE COUNTRY LOVERS"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 12.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/1"
            }
        }]],
        "C212": {
            "7140": "9781400098224",
            "7143": "EN"
        },
        "1082": 1,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["BLAKE, TON TEMPT ME TONIGHT"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "07",
                "3055": "28",
                "1131": "7B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 13.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/2"
            }
        }]],
        "C212": {
            "7140": "9780061136092",
            "7143": "EN"
        },
        "1082": 2,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["MONING, KA BLOODFEVER"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 6,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 22
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/3"
            }
        }]],
        "C212": {
            "7140": "9780385339162",
            "7143": "EN"
        },
        "1082": 3,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["MCKENNA, S EDGE OF MIDNIGHT"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/4"
            }
        }]],
        "C212": {
            "7140": "9780758211859",
            "7143": "EN"
        },
        "1082": 4,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["BALZO, SAN GROUNDS FOR MURDER"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 27.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/5"
            }
        }]],
        "C212": {
            "7140": "9780727865496",
            "7143": "EN"
        },
        "1082": 5,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["PALMER, DI HARD TO HANDLE"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 13.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/6"
            }
        }]],
        "C212": {
            "7140": "9780373772612",
            "7143": "EN"
        },
        "1082": 6,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["JONES, LLO MR PIP"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 20
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/7"
            }
        }]],
        "C212": {
            "7140": "9780385341066",
            "7143": "EN"
        },
        "1082": 7,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["JILES, PAU STORMY WEATHER"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 24.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/8"
            }
        }]],
        "C212": {
            "7140": "9780060537326",
            "7143": "EN"
        },
        "1082": 8,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["DELILLO, D FALLING MAN A NOVEL"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 26
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/9"
            }
        }]],
        "C212": {
            "7140": "9781416546023",
            "7143": "EN"
        },
        "1082": 9,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["MORRISON,  SWEETER THAN HONEY"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 24
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/10"
            }
        }]],
        "C212": {
            "7140": "9780758215116",
            "7143": "EN"
        },
        "1082": 10,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["SMITH, SHE FOX"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 25.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/11"
            }
        }]],
        "C212": {
            "7140": "9780756404215",
            "7143": "EN"
        },
        "1082": 11,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["GROSSMAN,  SOON I WILL BE INVINCIBL"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 22.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/12"
            }
        }]],
        "C212": {
            "7140": "9780375424861",
            "7143": "EN"
        },
        "1082": 12,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["LEWYCKA, M SHORT HISTORY OF TRACTOR"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 3,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/13"
            }
        }]],
        "C212": {
            "7140": "9780143036746",
            "7143": "EN"
        },
        "1082": 13,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["BANNISTER, FLAWED"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 4,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "03",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 24.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/14"
            }
        }]],
        "C212": {
            "7140": "9780312375669",
            "7143": "EN"
        },
        "1082": 14,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["ALEXANDER, REMEMBERED"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 13.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/15"
            }
        }]],
        "C212": {
            "7140": "9780764201103",
            "7143": "EN"
        },
        "1082": 15,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["TANIGUCHI, OCEAN IN THE CLOSET"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 2,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 14.95
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/16"
            }
        }]],
        "C212": {
            "7140": "9781566891943",
            "7143": "EN"
        },
        "1082": 16,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["HENKE, ROX SECRET OF US"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 13.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/17"
            }
        }]],
        "C212": {
            "7140": "9780736917018",
            "7143": "EN"
        },
        "1082": 17,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["HERMAN, KA EVER PRESENT DANGER"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 12.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/18"
            }
        }]],
        "C212": {
            "7140": "9781590529218",
            "7143": "EN"
        },
        "1082": 18,
        "1229": "5"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["CHAPMAN, G IT HAPPENS EVERY SPRING"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 5,
                "6063": "83"
            }
        }], ["FTX", {
            "C107": {
                "4441": "07",
                "3055": "28",
                "1131": "7B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 12.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/19"
            }
        }]],
        "C212": {
            "7140": "9781414311654",
            "7143": "EN"
        },
        "1082": 19,
        "1229": "24"
    }], ["LIN", {
        "SG26": [["IMD", {
            "C273": {
                "7008": ["JACKSON, N YADA YADA PRAYER GROUP G"]
            },
            "7077": "F",
            "7081": "BST"
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "21"
            }
        }], ["QTY", {
            "C186": {
                "6060": 8,
                "6063": "12"
            }
        }], ["QTY", {
            "C186": {
                "6060": 0,
                "6063": "85"
            }
        }], ["FTX", {
            "C107": {
                "4441": "01",
                "3055": "28",
                "1131": "8B"
            },
            "4451": "LIN"
        }], ["PRI", {
            "C509": {
                "5387": "SRP",
                "5125": "AAB",
                "5118": 13.99
            }
        }], ["RFF", {
            "C506": {
                "1153": "LI",
                "1154": "4641/20"
            }
        }]],
        "C212": {
            "7140": "9781591453628",
            "7143": "EN"
        },
        "1082": 20,
        "1229": "5"
    }], ["UNS", {
        "0081": "S"
    }], ["CNT", {
        "C270": {
            "6069": "2",
            "6066": 20
        }
    }], ["UNT", {
        "0074": 171,
        "0062": "725"
    }]]
}],
"recipient": "8888888",
"sender": "1556150",
"header": ["UNB", {
    "S003": {
        "0007": "31B",
        "0010": "8888888"
    },
    "0020": "2045",
    "S004": {
        "0019": 1556,
        "0017": 70618
    },
    "S001": {
        "0001": "UNOC",
        "0002": 3
    },
    "S002": {
        "0007": "31B",
        "0004": "1556150"
    }
}],
"sender_qual": "31B",
"UNA": {
    "seg_term": "'",
    "decimal_sign": ".",
    "esc_char": "?",
    "de_sep": "+",
    "ce_sep": ":",
    "rep_sep": " "
},
"recipient_qual": "31B"
}
