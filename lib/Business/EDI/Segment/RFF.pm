package Business::EDI::Segment::RFF;

use strict;
use warnings;
use Carp;

use base qw/Business::EDI::Segment/;

=pod

our $AUTOLOAD;
sub DESTROY {}
sub AUTOLOAD {
    my $self = shift;
    print STDERR __PACKAGE__ . "->AUTOLOADing\n";
    $Business::EDI::Segment::AUTOLOAD = $AUTOLOAD;
    $self->SUPER::AUTOLOAD(@_);
}

=cut

our $VERSION = 0.01;

our $debug = 0;
our $top   = 'C506';
our @codes = (
    'C506',
    1153,
    1154,
    1156,
    4000,
    1060,
    'debug'
);
our @required_codes = (1153);

sub carp_error {
    carp __PACKAGE__ . ' : ' . shift;
    return;   
}

sub new {
    my $class = shift;
    my $body  = shift;
    unless ($body) {
        return carp_error " new() called with EMPTY 1st argument";
    }
    my $obj = $class->SUPER::unblessed($body, \@codes, $debug);
    unless ($obj) {
        carp "Unblessed object creation failed";
        return;
    }
    my $self = bless($obj, $class);
    # print "blessed: " , Dumper($self);  use Data::Dumper;
    foreach (@required_codes) {
        unless (defined $obj->part($top)->part($_)) {
            return carp_error "Required field $top/$_ not populated";
        }
    }
    return $self;
}

1;
__END__

