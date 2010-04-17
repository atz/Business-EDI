package Business::EDI::Segment::RFF;

use strict;
use warnings;
use Carp;
use Business::EDI::DataElement;
use Business::EDI::CodeList;

our $AUTOLOAD;
our $VERSION = 0.01;

our $debug = 0;
our $top   = 'C506';
our @codes = (
    1153,
    1154,
    1156,
    4000,
    1060,
    'debug'
);
our @required_codes = (1153);

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
    $body->{$top} or return carp_error "Required code $top not found";
    foreach (@required_codes) {
        defined($body->{$top}->{$_}) or return carp_error "Required code $top/$_ not found";
    }
    $debug and print STDERR "good: we got a body, with a $top and required codes\n";
    my $self = bless({}, $class);
    foreach (@codes) {
        $self->{_permitted}->{$_} = 1;
        if ($body->{$top}->{$_}) {
            $self->{$_} = Business::EDI::DataElement->new($_, $body->{$top}->{$_});
                     # || Business::EDI::CodeList->new(   $_, $body->{$top}->{$_});
        }
    }
    $self->debug($debug);
    return $self;
    my $rcq = $body->{$top}->{1153};
    $rcq eq 'LI'    or return carp_error "$top/1153 is '$rcq' not 'LI'";
    $body->{$top}->{1154};
}

sub DESTROY {}
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

