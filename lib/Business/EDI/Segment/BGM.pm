package Business::EDI::Segment::BGM;

use strict;
use warnings;

use Carp;
use Business::EDI::DataElement;
use Business::EDI::CodeList;

our $AUTOLOAD;
our $VERSION = 0.01;

our $debug = 0;
our @codes = (
    1001,
    1131,
    3055,
    1000,
  # C106,
    1004,
    1056,
    1060,
    1225,
    4343,
    'debug'
);
our @required_codes = ();

sub carp_error {
    carp __PACKAGE__ . ': ' . shift;
    return;   
}

sub new {
    my $class = shift;
    my $body  = shift;
    
    unless ($body and ref($body) and ref($body) eq 'HASH') {
        return carp_error "argument to new() must be HASHREF";
    }
    $debug and print STDERR "good: we got a body and required codes\n";
    my $self = bless({}, $class);
    foreach (@codes) {
        $self->{_permitted}->{$_} = 1;
        if ($body->{$_}) {
            my $ref = ref($body->{$_});
            unless ($ref) {
                $self->{$_} = Business::EDI::DataElement->new($_, $body->{$_});
                next;   #like Business::EDI::DataElement->new('1225', '582830');
            }
            if ('HASH' eq $ref) {
                if (scalar keys(%$ref) == 1) {
                    my $key = (keys(%$ref))[0];
                    $self->{$_} = Business::EDI::CodeList->new_codelist($key, $body->{$_}->{$key});
                } else {
                    carp "HASH ref in body has unexpected number of keys: " . scalar keys(%$ref);
                }
            } else {
                carp "Strange ref in body argument, expected HASH ref, got $ref ref.  Ignoring.";
            }
        }
    }
    $self->debug($debug);
    return $self;
}

sub DESTROY {}  #
sub AUTOLOAD {
    my $self  = shift;
    my $class = ref($self) or croak "AUTOLOAD error: $self is not an object";
    my $name  = $AUTOLOAD;

    $name =~ s/.*://;   #   strip leading package stuff
    $name =~ s/^s(eg(ment)?)?//i;  #   strip segment (to avoid numerical method names)

    unless (exists $self->{_permitted}->{$name}) {
        croak "Cannot access '$name' field of class '$class'"; 
    }

    if (@_) {
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

1;
__END__

Data comes in looking like, where the hashref is what gets passed to new():

    'BGM',
    {
        '1004' => '582822',
        '4343' => 'AC',
        '1225' => '29',     # ACCEPTED!
        'C002' => { '1001' => '231' }
    }

From the ORDRSP spec:

BGM - Beginning of message

A segment by which the sender must uniquely identify the order response by means of its number and when necessary its function.

 MESSAGE |
FUNCTION | Meaning
    CODE |
=================================================================
      12 | Total message was NOT processed, rejected or accepted. 
      27 | Rejected
      29 | ACCEPTED  (w/o Amendment)

      28 | Accepted w/ Amendment in Heading info 
      30 | Accepted w/ Amendment in Detail section (LIN)
      34 | Accepted w/ Amendment in Heading AND Detail

      12 | NOT PROCESSED: acknowledgement of receipt by seller, but remains to be processed within his application system.
       2 | NOT ACCEPTED

If 28 or 34, then all segments in the heading section must be used from the ORDRES or ORDCHG message being responded to. This includes both amended and non amended segments.
For 28, the Detail Section is considered as acknowledged without change.
