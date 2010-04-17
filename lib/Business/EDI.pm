package Business::EDI;

use strict;
use warnings;
# use Carp;
# use Data::Dumper;

our $VERSION = 0.01;

use Business::EDI::CodeList;
# our $verbose = 0;

sub new {
    my($class, %args) = @_;
    my $self = bless(\%args, $class);
    # $self->{args} = {};
    return $self;
}

sub codelist {
    my $self = shift;
    Business::EDI::CodeList->new_codelist(@_);
}

sub segment {
    my $self = shift;
#    Business::EDI::Segment->new(@_);
}

sub message {
    my $self = shift;
#    Business::EDI::Message->new(@_);
}

sub dataelement {
    my $self = shift;
#    Business::EDI::DataElement->new(@_);
}

1;
__END__

=head1 NAME

Business::EDI - Top level class for generating U.N. EDI interchange objects and subobjects.

=head1 SYNOPSIS

  use Business::EDI;
  
  my $rtc = Business::EDI->codelist('ResponseTypeCode', $json) or die "Unrecognized code!";
  printf "EDI response type: %s - %s (%s)\n", $rtc->code, $rtc->label, $rtc->value;

=head1 DESCRIPTION

At present, the EDI input processed by Business::EDI objects is JSON from the B<edi4r> ruby library.  

=head1 WARNINGS

This code is preliminary.  EDI is a big spec with many revisions, and the coverage for all 
segments, elements and message types is not yet present.  At the lowest level, all codelists from the most recent
spec (D09B) are present.  

=head1 SEE ALSO

edi4r - http://edi4r.rubyforge.org

=head1 AUTHOR

Joe Atzberger

